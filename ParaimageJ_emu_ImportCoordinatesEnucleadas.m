% Preprocessing

clear all
close all

% Run date & time
run_date = char(datetime('now','Format','yyyy-MM-dd_HH.mm''''ss''''''''')) ;

% Select dir containing .xlsx track files
topLevelFolder = uigetdir('C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers sin nucleo\mov.sist.enucleadas') ;

% Create destination folder
destination_folder = strcat(fileparts(topLevelFolder), '\ParaImagejEmu_', run_date) ;
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

% Custom pixel/mm ratio list for galvanotaxis cells
ratio_list1 = [38.6252,38.6252,38.6252,11.63,11.63,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252] ;

% Custom pixel/mm ratio list for chemotaxis cells
ratio_list2 = [38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,38.6252,11.63] ;

bar1 = waitbar(0,'In progress...','Name','Scenario') ;
bar1.Children.Title.Interpreter = 'none';
bar2 = waitbar(0,'In progress...','Name','Excel file') ;
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
    
    % Sort file names in natural order 
    files = natsortfiles(files) ;
    
    % Initialize condition track figure
    figures.(conditionValidName).tracks = figure('Name',strcat('Tracks',condition),...
        'Visible','off','NumberTitle','off') ;
    hTracks = gca;
    
    % Retrieve tracks from scenario's xlsx files
    for l = 1:length(files)
        thisxlsx = files(l).name ;
        % opts = detectImportOptions(thisxlsx);
        % opts.SelectedVariableNames = ["Var5" "Var6" "Var8"]; % (columns) XY-coordinates and data point sequence
        temp_xlsx = readmatrix(thisxlsx,'Range','E:H');
        ix = cumsum(temp_xlsx(:,4) < circshift(temp_xlsx(:,4),1,1));
        series = splitapply(@(x1){x1},temp_xlsx(:,1:2),ix);
        for s = 1:length(series)
            tracks.(conditionValidName).(matlab.lang.makeValidName(thisxlsx(1:end-5))).(genvarname(num2str(s))) = series{s};
        end
        waitbar(l/length(files), bar2, matlab.lang.makeValidName(thisxlsx(1:end-5))) ;    
    end

    % Loop for track importing and processing
    A = fieldnames(tracks.(conditionValidName)) ;
    for i = 1:length(A)
        B = fieldnames(tracks.(conditionValidName).(A{i})) ;
        for j = 1:length(B)           
            
            % Add current track to the "condition" tracks plot and place black dot marker at its tip
            centeredX = tracks.(conditionValidName).(A{i}).(B{j})(:,1) - tracks.(conditionValidName).(A{i}).(B{j})(1,1);
            centeredY = tracks.(conditionValidName).(A{i}).(B{j})(:,2) - tracks.(conditionValidName).(A{i}).(B{j})(1,2);
            plot(hTracks,centeredX,centeredY, 'Color', [0, 0, 0]) ;
            hold on;
            plot(hTracks, centeredX(end), centeredY(end),'ko',...
                'MarkerFaceColor',  [0, 0, 0], 'MarkerSize', 2) ;
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
    
    % update condition/subfolder progress bar
    waitbar(f/length(UsefulSubFolderNames), bar1, condition) ;    
end

close(bar1,bar2)
tImportSec = num2str(toc(tImportSec)) ;

% Save data
save(strcat(destination_folder, '\ParaImageJ_emu_', run_date, '_trajectories.mat'),...
    'tracks') ;

['ParaImageJEmu section FINISHED in ', tImportSec, ' seconds']

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