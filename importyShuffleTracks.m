%% Track extraction and plotting

clear
close all

% Run date & time
run_date = char(datetime('now','Format','yyyy-MM-dd_HH.mm''''ss''''''''')) ;

% Select dir containing .xlsx track files
topLevelFolder = uigetdir('C:\Users') ;

% Number of times Rho(s) will be randomly permuted to test against the
% null hypothesis that results are random
shuffles = 200000;

% Create destination folder
destination_folder = strcat(fileparts(fileparts(topLevelFolder)), '\', run_date, '_', ...
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
for ii = 1 : length(UsefulSubFolderNames)
	fprintf('Sub folder #%d = %s\n', ii, UsefulSubFolderNames{ii}) ;
end

% Initialize track struct
tracks = struct ;

% Custom pixel/mm ratio list for galvanotaxis_cells
ratio_list1 = [38.6252,38.6252,38.6252,11.63,11.63,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252] ;

% Custom pixel/mm ratio list for chemotaxis_cells
ratio_list2 = [38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,11.63] ;

bar1 = waitbar(0,'In progress...','Name','Scenario') ;
bar1.Children.Title.Interpreter = 'none';
bar2 = waitbar(0,'In progress...','Name','Track') ;
bar2.Children.Title.Interpreter = 'none';

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
    waitbar(f/length(UsefulSubFolderNames), bar1, condition) ;

    % Sort file names in natural order 
    files = enu.natsortfiles(files) ;
    
    % Initialize condition track figure
    figures.(conditionValidName).tracks = figure('Name',strcat('Tracks',condition),...
        'Visible','off','NumberTitle','off') ;
    hTracks = gca;
    
    % Retrieve tracks from usefulsubfolder xlsx files
    for l = 1:length(files)
        thisxlsx = files(l).name ;
        A = matlab.lang.makeValidName(thisxlsx(1:end-5));
        
        % opts = detectImportOptions(thisxlsx);
        % opts.SelectedVariableNames = ["Var5" "Var6" "Var8"]; % (columns) XY-coordinates and data point sequence
        temp_xlsx = readmatrix(thisxlsx, 'Range','E:H');
        ix = cumsum(temp_xlsx(:,4) < circshift(temp_xlsx(:,4),1,1));
        series = splitapply(@(x1){x1},temp_xlsx(:,1:2),ix);
        for s = 1:length(series)
            tracktime = tic;
            waitbar(l/length(files), bar2, strcat(A,'nº',num2str(s))) ;         
            B = genvarname(num2str(s));
            tracks.(conditionValidName).(A).(B).original = series{s};

            % Center X and Y coordinates (substract first value to all series)
            tracks.(conditionValidName).(A).(B).centered = ...
                tracks.(conditionValidName).(A).(B).original - tracks.(conditionValidName).(A).(B).original(1,:) ;
            
            % Polar coordinate conversion
            [tracks.(conditionValidName).(A).(B).theta,...
                tracks.(conditionValidName).(A).(B).rho] = ...
                cart2pol(tracks.(conditionValidName).(A).(B).centered(:,1),...
                tracks.(conditionValidName).(A).(B).centered(:,2)) ;
            
            % Scale X, Y and Rho
            if contains(conditionValidName, 'galvanotaxis_Cells')
                tracks.(conditionValidName).(A).(B).scaled_rho = ...
                    tracks.(conditionValidName).(A).(B).rho/ratio_list1(l) ;
                tracks.(conditionValidName).(A).(B).scaled = ...
                    tracks.(conditionValidName).(A).(B).centered/ratio_list1(l) ;
            elseif contains(conditionValidName, 'chemotaxis_Cells')
                tracks.(conditionValidName).(A).(B).scaled_rho = ...
                    tracks.(conditionValidName).(A).(B).rho/ratio_list2(l) ;
                tracks.(conditionValidName).(A).(B).scaled = ...
                    tracks.(conditionValidName).(A).(B).centered/ratio_list2(l) ;
            else
                tracks.(conditionValidName).(A).(B).scaled_rho = ...
                    tracks.(conditionValidName).(A).(B).rho/39.6252 ;
                tracks.(conditionValidName).(A).(B).scaled = ...
                    tracks.(conditionValidName).(A).(B).centered/39.6252 ;                
            end
            
            % Shuffling
            toShuffle = [tracks.(conditionValidName).(A).(B).scaled,tracks.(conditionValidName).(A).(B).scaled_rho];

            for kk=1:shuffles
                  toShuffle = enu.Shuffle(toShuffle,1);
            end

            tracks.(conditionValidName).(A).(B).shuffled = toShuffle(:,1:2);

            tracks.(conditionValidName).(A).(B).shuffled_rho = toShuffle(:,3);
            
            % Add current track to the "condition" tracks plot and place black dot marker at its tip      
            plot(hTracks,tracks.(conditionValidName).(A).(B).scaled(:,1),...
                tracks.(conditionValidName).(A).(B).scaled(:,2), 'Color', 'k') ;
            hold on;
            plot(hTracks,tracks.(conditionValidName).(A).(B).scaled(end,1),...
                tracks.(conditionValidName).(A).(B).scaled(end,2),...
                'ko',  'MarkerFaceColor',  'k', 'MarkerSize', 2) ;
            ['Track ' A 'nº' B ' time elapsed ' num2str(toc(tracktime)) ' seconds']
        end
    end

    % Adjust track plot axes' proportions
    hold on
    box on
    MaxX = max(abs(hTracks.XLim))+1;
    MaxY = max(abs(hTracks.YLim))+1;
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
    
    [condition ' elapsed time was ' num2str(toc(thisfoldertic)) ' seconds']
    
    % %Save track plot as jpg
    % exportgraphics(hTracks,strcat(destination_folder, strcat('\Tracks',condition),'.jpg'), ...
    % "Resolution",300)
    
end

tImportSec = num2str(toc(tImportSec)) ;
['Track loading and shuffling section elapsed time ', tImportSec, ' seconds']


close(bar1,bar2)
% Save data
save(strcat(destination_folder, '\', run_date, '_trajectories.mat'),...
    'tracks','figures','tImportSec','destination_folder','run_date') ;

clear thisfoldertic tImportSec

% Export figures as .jpg
disp('Exporting figures in jpg format')
FigList = findobj(allchild(0), 'flat', 'Type', 'figure', '-not','Tag','TMWWaitbar') ;
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig) ;
  FigName = get(FigHandle,'Name') ;
  set(0, 'CurrentFigure', FigHandle) ;
  annotation('textbox',[.3 .9 .8 .1],'String',FigName,'EdgeColor','none','Interpreter','none','FontSize',12)
  exportgraphics(FigHandle,strcat(destination_folder,'\', FigName,'.jpg'), "Resolution",300)
end

diary off
