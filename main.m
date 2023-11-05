%% Preprocessing

% Run date & time
run_date = char(datetime('now','Format','yyyy-MM-dd_HH.mm''''ss''''''''')) ;

% Select dir containing .xlsx track files
topLevelFolder = uigetdir('C:\') ;

% Number of times Rho(s) will be randomly permuted to test against the
% null hypothesis that results are random
shuffles = 200000;

% Create destination folder
destination_folder = strcat(fileparts(topLevelFolder), '\', run_date, '_', ...
    num2str(shuffles), '_shuffles') ;
mkdir(destination_folder) ;

% Initialize log
diary off
diary_filename = strcat(destination_folder,'\MatlabCommandWindowlog_', run_date,'.txt') ;
set(0,'DiaryFile',diary_filename)
clear diary_filename
diary on

% Get a list of all .xlsx files and their containing subfolders in this
% directory
AllDirs = dir(fullfile(topLevelFolder, '**\*\*\*.xlsx')) ;

% Dump folder names from .folder field of "AllDirs" struct into a cell
% array
AllsubFolderNames = {AllDirs.folder} ;

% Filter unique instances of names
UsefulSubFolderNames = unique(AllsubFolderNames, 'sorted') ;

% Display subfolders' name on the console
for k = 1 : length(UsefulSubFolderNames)
	fprintf('Sub folder #%d = %s\n', k, UsefulSubFolderNames{k}) ;
end

% List the parameters to be calculated by the script
stat_names = {'RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2', 'sRMSF_R2', 'RMSFCorrelationTime', ...
    'sRMSFCorrelationTime', 'DFA_gamma', 'sDFA_gamma', 'MSD_beta', 'sMSD_beta', 'ApEn', ...
    'sApEn','Intensity','sIntensity','DR','sDR','AvgSpeed','sAvgSpeed','DisplacementCosines'} ;

% Initialize bulk data structures
tracks = struct ;
coordinates = struct ;
results = struct ;

% Custom pixel/mm ratio list for galvanotaxis cells
ratio_list1 = ...
[
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [11.63,11.63,11.63,11.63,11.63,11.63,11.63],...
    [11.63,11.63,11.63,11.63,11.63,11.63,11.63,11.63],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252]
] ;

% Custom pixel/mm ratio list for chemotaxis cells
ratio_list2 = ...
[
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [38.6252,38.6252,38.6252,38.6252],...
    [11.63,11.63,11.63,11.63,11.63,11.63,11.63,11.63],...
] ;

bar1 = waitbar(0,'In progress...','Name','Reading condition files...') ;
bar2 = waitbar(0,'In progress...','Name','Reading file...') ;


%% Track extraction and plotting

tImportSec = tic;

for f = 1:length(UsefulSubFolderNames)

    % Find all subfolders containing xlsx files
    thisfoldertic = tic;
    cd(UsefulSubFolderNames{f})
    files = dir('*.xlsx') ;
    
    % Store valid condition names as a variable
    [~,name2,name3] = fileparts(pwd) ;
    disp(name2(1:end-3))
    condition = strcat(name2, name3) ;
    conditionValidName = matlab.lang.makeValidName(condition) ;
    
    % update condition/subfolder progress bar
    bar1 = waitbar(f/length(UsefulSubFolderNames), bar1, condition) ;

    % Sort file names in natural order 
    files = natsortfiles(files) ;
    
    % Initialize condition track figure
    figures.(conditionValidName).tracks = figure('Name',strcat('Tracks_',condition),...
        'Visible','off','NumberTitle','off') ;
    hTracks = gca;
    
    % Retrieve tracks from condition's xlsx files
    condition_track_n = 0 ;
    for l = 1:length(files)
        thisxlsx = files(l).name ;
        opts.SelectedVariableNames = ["Var5" "Var6" "Var8"]; % (columns) XY-coordinates and data point sequence
        temp_xlsx = readmatrix(thisxlsx, opts);
        

        
        startRow = 1;  %starting row number
        nRows = 3600;  %number of rows in segment
        totalRows = size(temp_xlsx,1) ;  %number of total rows
        nSegments = floor((totalRows - startRow + 1) / nRows);  %number of complete segments
        nLeftover = totalRows - startRow + 1 - (nSegments * nRows);  %number of rows at end that will be ignored
        [name2(1:end-3) ' ' thisxlsx ' ' 'contains' ' ' num2str(nSegments) ' ' 'tracks' ' ' 'with' ' ' num2str(nLeftover) ' ' 'leftover']
        if nLeftover ~= 0
            disp(nLeftover)
            error('File contains one or more tracks of length not equal to 3600')
        end
        % Compute start and end indices of each segment
        segStart = startRow : nRows : totalRows ;
        segStop = segStart(2)-1 : nRows : totalRows ;
        segment = cell(nSegments, 1) ;
        % Save each track separately
        for s = 1:nSegments
            % This is the s_th section:
            condition_track_n = condition_track_n + 1 ;
            tracks.(conditionValidName).(genvarname(num2str(condition_track_n))) = ...
                temp_xlsx(segStart(s) : segStop(s), :) ; 
        end
    end

    % Tracks loop
    A = fieldnames(tracks.(conditionValidName)) ;
    for i = 1:length(A)
        
        thisfiletic = tic;
      
        % update track progress bar
        bar2 = waitbar(i/length(A), bar2, A{i}) ;
             
        % Save original X and Y coordinates as x(i) and y(i)
        coordinates.(conditionValidName).original_x(:,i) = tracks.(conditionValidName).(A{i})(:,1) ;
        coordinates.(conditionValidName).original_y(:,i) = tracks.(conditionValidName).(A{i})(:,2) ;
        
        % Center X and Y coordinates (substract first value to all series)
        coordinates.(conditionValidName).centered_x(:,i) = ...
            coordinates.(conditionValidName).original_x(:,i) - coordinates.(conditionValidName).original_x(1,i) ;
        coordinates.(conditionValidName).centered_y(:,i) = ...
            coordinates.(conditionValidName).original_y(:,i) - coordinates.(conditionValidName).original_y(1,i) ;
        
        % Polar coordinate conversion
        [coordinates.(conditionValidName).theta(:,i),...
            coordinates.(conditionValidName).rho(:,i)] = ...
            cart2pol(coordinates.(conditionValidName).centered_x(:,i),...
            coordinates.(conditionValidName).centered_y(:,i)) ;
        
        % Scale Rho, X, and Y
        if contains(condition, '11.63')
            coordinates.(conditionValidName).scaled_rho(:,i) = ...
                coordinates.(conditionValidName).rho(:,i)/11.63 ;
            coordinates.(conditionValidName).scaled_x(:,i) = ...
                coordinates.(conditionValidName).centered_x(:,i)/11.63 ;
            coordinates.(conditionValidName).scaled_y(:,i) = ...
                coordinates.(conditionValidName).centered_y(:,i)/11.63 ;
        elseif contains(condition, '23.44')
            coordinates.(conditionValidName).scaled_rho(:,i) = ...
                coordinates.(conditionValidName).rho(:,i)/23.44 ;
            coordinates.(conditionValidName).scaled_x(:,i) = ...
                coordinates.(conditionValidName).centered_x(:,i)/23.44 ;
            coordinates.(conditionValidName).scaled_y(:,i) = ...
                coordinates.(conditionValidName).centered_y(:,i)/23.44 ;
        else
            coordinates.(conditionValidName).scaled_rho(:,i) = ...
                coordinates.(conditionValidName).rho(:,i)/ratio_list(i) ;
            coordinates.(conditionValidName).scaled_x(:,i) = ...
                coordinates.(conditionValidName).centered_x(:,i)/ratio_list(i) ;
            coordinates.(conditionValidName).scaled_y(:,i) = ...
                coordinates.(conditionValidName).centered_y(:,i)/ratio_list(i) ;
        end
        
        % Shuffle X and Y trajectories
        coordinates.(conditionValidName).shuffled_x(:,i) = ...
            coordinates.(conditionValidName).scaled_x(:,i) ; % initialize shuffled X

        coordinates.(conditionValidName).shuffled_y(:,i) = ...
            coordinates.(conditionValidName).scaled_y(:,i) ; % initialize shuffled Y
            
        for k=1:shuffles
          coordinates.(conditionValidName).shuffled_x(:,i) = ...
              shuff(coordinates.(conditionValidName).shuffled_x(:,i)) ;

          coordinates.(conditionValidName).shuffled_y(:,i) = ...
              shuff(coordinates.(conditionValidName).shuffled_y(:,i)) ;
        end
        
        % Shuffle Scaled_Rho
        coordinates.(conditionValidName).shuffled_rho(:,i) = ...
            coordinates.(conditionValidName).scaled_rho(:,i) ;
        
        for k=1:shuffles
          coordinates.(conditionValidName).shuffled_rho(:,i) = ...
              shuff(coordinates.(conditionValidName).shuffled_rho(:,i)) ;
        end
        
        % Plot trajectory and place black dot marker at its tip      
        plot(hTracks,coordinates.(conditionValidName).scaled_x(:,i),...
            coordinates.(conditionValidName).scaled_y(:,i), 'Color', [0, 0, 0]) ;
        hold on;
        plot(hTracks,coordinates.(conditionValidName).scaled_x(end,i),...
            coordinates.(conditionValidName).scaled_y(end,i),...
            'ko',  'MarkerFaceColor',  [0, 0, 0], 'MarkerSize', 2) ;
        
        [A{i} ' runtime was ' num2str(toc(thisfiletic)) ' seconds']
    end
    % Adjust track plot axes' proportions
    hold on
    box on
    MaxX = max(abs(hTracks.XLim))+1;   MaxY = max(abs(hTracks.YLim))+1;
    % Add x-line
    x = 0; 
    xl = plot([x,x],ylim(hTracks), 'k-', 'LineWidth', .5);
    % Add y-line
    y = 0; 
    yl = plot(xlim(hTracks), [y, y], 'k-', 'LineWidth', .5);
    % Send x and y lines to the bottom of the stack
    uistack([xl,yl],'bottom')
    % Update the x and y line bounds any time the axes limits change
    hTracks.XAxis.LimitsChangedFcn = @(ruler,~)set(xl, 'YData', ylim(ancestor(ruler,'axes')));
    hTracks.YAxis.LimitsChangedFcn = @(ruler,~)set(yl, 'XData', xlim(ancestor(ruler,'axes')));
    axis equal
    if MaxX > MaxY
        axis([-MaxX MaxX -MaxY*(MaxX/MaxY) MaxY*(MaxX/MaxY)]);
    elseif MaxY > MaxX
        axis([-MaxX*(MaxY/MaxX) MaxX*(MaxY/MaxX) -MaxY MaxY]);
    elseif MaxY == MaxX
        axis([-MaxX MaxX -MaxY MaxY]);
    end
    hold off
    
    [condition ' runtime was ' num2str(toc(thisfoldertic)) ' seconds']
end

tImportSec = num2str(toc(tImportSec)) ;

% Save data
save(strcat(destination_folder, '\', run_date, '_coordinates.mat'),...
    'coordinates','figures','stat_names','shuffles','tImportSec','destination_folder') ;

['Coordinate section FINISHED in ', tImportSec, ' seconds']