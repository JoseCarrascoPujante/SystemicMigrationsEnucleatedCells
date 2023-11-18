% Preprocessing

clear
close all

% Run date & time
run_date = char(datetime('now','Format','yyyy-MM-dd_HH.mm''''ss''''''''')) ;

% Select dir containing .xlsx track files
topLevelFolder = uigetdir('C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas') ;

% Number of times Rho(s) will be randomly permuted to test against the
% null hypothesis that results are random
shuffles = 200000;

% Create destination folder
destination_folder = strcat(fileparts(topLevelFolder), '\ParaImagejEmu_', run_date, '_', ...
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
ratio_list1 = [38.6252,38.6252,38.6252,11.63,11.63,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252] ;

% Custom pixel/mm ratio list for chemotaxis cells
ratio_list2 = [38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,11.63] ;

bar1 = waitbar(0,'In progress...','Name','Reading scenario_condition files in:') ;
bar1.Children.Title.Interpreter = 'none';
bar2 = waitbar(0,'In progress...','Name','Reading file nº:') ;
bar2.Children.Title.Interpreter = 'none';


%% Track extraction and plotting

tImportSec = tic;

for f = 1:length(UsefulSubFolderNames)

    % Find all subfolders containing xlsx files
    thisfoldertic = tic;
    cd(UsefulSubFolderNames{f})
    files = dir('*.xlsx') ;
    
    % Store valid condition names as a variable
    parts = strsplit(pwd, '\');
    condition = strcat(parts{end-1}, '_', parts{end}) ;
    disp(['Now parsing:', ' "', condition,'"'])
    conditionValidName = matlab.lang.makeValidName(condition) ;
    
    % update condition/subfolder progress bar
    bar1 = waitbar(f/length(UsefulSubFolderNames), bar1, condition) ;

    % Sort file names in natural order 
    files = natsortfiles(files) ;
    
    % Initialize condition track figure
    figures.(conditionValidName).tracks = figure('Name',strcat('Tracks_',condition),...
        'Visible','off','NumberTitle','off') ;
    hTracks = gca;
    
    % Retrieve tracks from scenario's xlsx files
    scenario_cell_count = 0 ;
    for l = 1:length(files)
        thisxlsx = files(l).name ;
        opts = detectImportOptions(thisxlsx);
        opts.SelectedVariableNames = ["Var5" "Var6" "Var8"]; % (columns) XY-coordinates and data point sequence
        temp_xlsx = readmatrix(thisxlsx, opts);
        ix = cumsum(temp_xlsx(:,3) < circshift(temp_xlsx(:,3),1,1));
        series = splitapply(@(x1){x1},temp_xlsx(:,1:2),ix);
        for s = 1:length(series)
            scenario_cell_count = scenario_cell_count + 1;            
            tracks.(conditionValidName).(matlab.lang.makeValidName(thisxlsx(1:end-5))).(genvarname(num2str(scenario_cell_count))) = series{s};
        end
    end

    % Loop for track importing and processing
    A = fieldnames(tracks.(conditionValidName)) ;
    for i = 1:length(A)
        B = fieldnames(tracks.(conditionValidName).(A{i})) ;
        % update track progress bar
        bar2 = waitbar(i/length(A), bar2, A{i}) ;
        for j = 1:length(B)
             
            % Save original X and Y coordinates as x(i) and y(i)
            coordinates.(conditionValidName).(A{i}).original_x{j} = tracks.(conditionValidName).(A{i}).(B{j})(:,1) ;
            coordinates.(conditionValidName).(A{i}).original_y{j} = tracks.(conditionValidName).(A{i}).(B{j})(:,2) ;
            
            % Center X and Y coordinates (substract first value to all series)
            coordinates.(conditionValidName).(A{i}).centered_x{j} = ...
                coordinates.(conditionValidName).(A{i}).original_x{j} ...
                - coordinates.(conditionValidName).(A{i}).original_x{j}(1) ;
            coordinates.(conditionValidName).(A{i}).centered_y{j} = ...
                coordinates.(conditionValidName).(A{i}).original_y{j} ...
                - coordinates.(conditionValidName).(A{i}).original_y{j}(1) ;
            
            % Polar coordinate conversion
            [coordinates.(conditionValidName).(A{i}).theta{j},...
                coordinates.(conditionValidName).(A{i}).rho{j}] = ...
                cart2pol(coordinates.(conditionValidName).(A{i}).centered_x{j},...
                coordinates.(conditionValidName).(A{i}).centered_y{j}) ;
            
            % Scale Rho, X, and Y
            if contains(condition, 'Galvanotaxis_Cells')
                coordinates.(conditionValidName).(A{i}).scaled_rho{j} = ...
                    coordinates.(conditionValidName).(A{i}).rho{j}/ratio_list1(i) ;
                coordinates.(conditionValidName).(A{i}).scaled_x{j} = ...
                    coordinates.(conditionValidName).(A{i}).centered_x{j}/ratio_list1(i) ;
                coordinates.(conditionValidName).(A{i}).scaled_y{j} = ...
                    coordinates.(conditionValidName).(A{i}).centered_y{j}/ratio_list1(i) ;
            elseif contains(condition, 'Chemotaxis_Cells')
                coordinates.(conditionValidName).(A{i}).scaled_rho{j} = ...
                    coordinates.(conditionValidName).(A{i}).rho{j}/ratio_list2(i) ;
                coordinates.(conditionValidName).(A{i}).scaled_x{j} = ...
                    coordinates.(conditionValidName).(A{i}).centered_x{j}/ratio_list2(i) ;
                coordinates.(conditionValidName).(A{i}).scaled_y{j} = ...
                    coordinates.(conditionValidName).(A{i}).centered_y{j}/ratio_list2(i) ;
            else
                coordinates.(conditionValidName).(A{i}).scaled_rho{j} = ...
                    coordinates.(conditionValidName).(A{i}).rho{j}/39.6252 ;
                coordinates.(conditionValidName).(A{i}).scaled_x{j} = ...
                    coordinates.(conditionValidName).(A{i}).centered_x{j}/39.6252 ;
                coordinates.(conditionValidName).(A{i}).scaled_y{j} = ...
                    coordinates.(conditionValidName).(A{i}).centered_y{j}/39.6252 ;
            end
            
            % % Shuffle X and Y trajectories
            % 
            % % initialize shuffled X
            % coordinates.(conditionValidName).(A{i}).shuffled_x{j} = ...
            %     coordinates.(conditionValidName).(A{i}).scaled_x{j} ; 
            % % initialize shuffled Y
            % coordinates.(conditionValidName).(A{i}).shuffled_y{j} = ...
            %     coordinates.(conditionValidName).(A{i}).scaled_y{j} ;
            % XYshufftime = tic;
            % for k=1:shuffles
            %   coordinates.(conditionValidName).(A{i}).shuffled_x{j} = ...
            %       shuff(coordinates.(conditionValidName).(A{i}).shuffled_x{j}) ;
            % 
            %   coordinates.(conditionValidName).(A{i}).shuffled_y{j} = ...
            %       shuff(coordinates.(conditionValidName).(A{i}).shuffled_y{j}) ;
            % end
            % [A{i}{j} ' XY shuffling runtime was ' num2str(toc(XYshufftime)) ' seconds']
            % 
            % % Shuffle Scaled_Rho
            %
            % % Initialize shuffled_rho
            % coordinates.(conditionValidName).(A{i}).shuffled_rho{j} = ...
            %     coordinates.(conditionValidName).(A{i}).scaled_rho{j} ;
            %
            % rhoShufftime = tic
            % for k=1:shuffles
            %   coordinates.(conditionValidName).(A{i}).shuffled_rho{j} = ...
            %       shuff(coordinates.(conditionValidName).(A{i}).shuffled_rho{j}) ;
            % end
            % [A{i}{j} ' RHO shuffling runtime was ' num2str(toc(rhoShufftime)) ' seconds']
            
            % Add current track to the "condition" tracks plot and place black dot marker at its tip      
            plot(hTracks,coordinates.(conditionValidName).(A{i}).scaled_x{j},...
                coordinates.(conditionValidName).(A{i}).scaled_y{j}, 'Color', [0, 0, 0]) ;
            hold on;
            plot(hTracks,coordinates.(conditionValidName).(A{i}).scaled_x{j}(end),...
                coordinates.(conditionValidName).(A{i}).scaled_y{j}(end),...
                'ko',  'MarkerFaceColor',  [0, 0, 0], 'MarkerSize', 2) ;
        end
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
    set(hTracks, 'YDir','reverse')
    hold off
    
    [condition ' runtime was ' num2str(toc(thisfoldertic)) ' seconds']
    
    % %Save figure as a jpg file
    % exportgraphics(hTracks,strcat(destination_folder, strcat('\Tracks_',condition),'.jpg'), ...
    % "Resolution",300)
    
end

tImportSec = num2str(toc(tImportSec)) ;

% Save data
save(strcat(destination_folder, '\ParaImagejEmu_', run_date, '_coordinates.mat'),...
    'coordinates','figures','stat_names','shuffles','tImportSec','destination_folder') ;

['Coordinate section FINISHED in ', tImportSec, ' seconds']

clear thisfoldertic tImportSec

% Export figures as .jpg
disp('Exporting figures in jpg format')
FigList = findobj(allchild(0), 'flat', 'Type', 'figure', '-not','Tag','TMWWaitbar') ;
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig) ;
  FigName = get(FigHandle,'Name') ;
  set(0, 'CurrentFigure', FigHandle) ;
  annotation('textbox',[.3 .9 .8 .1],'String',FigName,'EdgeColor','none','Interpreter','none','FontSize',12)
  exportgraphics(FigHandle,strcat(destination_folder,'\', FigName,'.jpg'), ...
  "Resolution",300)
end

diary off