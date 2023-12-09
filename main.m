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
            tracks.(conditionValidName).(A).original.(B) = series{s};

            % Center X and Y coordinates (substract first value to all series)
            tracks.(conditionValidName).(A).centered.(B) = ...
                tracks.(conditionValidName).(A).original.(B) - tracks.(conditionValidName).(A).original.(B)(1,:) ;
            
            % Polar coordinate conversion
            [tracks.(conditionValidName).(A).theta.(B),...
                tracks.(conditionValidName).(A).rho.(B)] = ...
                cart2pol(tracks.(conditionValidName).(A).centered.(B)(:,1),...
                tracks.(conditionValidName).(A).centered.(B)(:,2)) ;
            
            % Scale X, Y and Rho
            if contains(conditionValidName, 'galvanotaxis_Cells')
                tracks.(conditionValidName).(A).scaled_rho.(B) = ...
                    tracks.(conditionValidName).(A).rho.(B)/ratio_list1(l) ;
                tracks.(conditionValidName).(A).scaled.(B) = ...
                    tracks.(conditionValidName).(A).centered.(B)/ratio_list1(l) ;
            elseif contains(conditionValidName, 'chemotaxis_Cells')
                tracks.(conditionValidName).(A).scaled_rho.(B) = ...
                    tracks.(conditionValidName).(A).rho.(B)/ratio_list2(l) ;
                tracks.(conditionValidName).(A).scaled.(B) = ...
                    tracks.(conditionValidName).(A).centered.(B)/ratio_list2(l) ;
            else
                tracks.(conditionValidName).(A).scaled_rho.(B) = ...
                    tracks.(conditionValidName).(A).rho.(B)/39.6252 ;
                tracks.(conditionValidName).(A).scaled.(B) = ...
                    tracks.(conditionValidName).(A).centered.(B)/39.6252 ;                
            end
            
            % Shuffling
            toShuffle = [tracks.(conditionValidName).(A).scaled.(B),tracks.(conditionValidName).(A).scaled_rho.(B)];

            for kk=1:shuffles
                  toShuffle = enu.Shuffle(toShuffle,1);
            end

            tracks.(conditionValidName).(A).shuffled.(B) = toShuffle(:,1:2);

            tracks.(conditionValidName).(A).shuffled_rho.(B) = toShuffle(:,3);
            
            % Add current track to the "condition" tracks plot and place black dot marker at its tip      
            plot(hTracks,tracks.(conditionValidName).(A).scaled.(B)(:,1),...
                tracks.(conditionValidName).(A).scaled.(B)(:,2), 'Color', 'k') ;
            hold on;
            plot(hTracks,tracks.(conditionValidName).(A).scaled.(B)(end,1),...
                tracks.(conditionValidName).(A).scaled.(B)(end,2),...
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

%% Calculations

clear
close all

load("2023-12-08_17.17'38''_trajectories.mat")
tCalcSec=tic;

results = struct ;
% List the parameters to be calculated by the script
stat_names = {'RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2', 'RMSFCorrelationTime', ...
    'DFA_gamma', 'sDFA_gamma', 'MSD_beta', 'sMSD_beta', 'ApEn', 'sApEn', ...
    'Intensity','sIntensity','DR','sDR','AvgSpeed','sAvgSpeed','dispCos'} ;

bar3 = waitbar(0,'In progress...','Name','Scenario') ;
bar3.Children.Title.Interpreter = 'none';
bar4 = waitbar(0,'In progress...','Name','Track') ;
bar4.Children.Title.Interpreter = 'none';

C = fieldnames(tracks) ;
for ii = 1:length(C) %for condition...
    
    bar3 = waitbar(ii/length(C), bar3, C{ii}) ;
    
    scenariotime = tic;
       
    S = fieldnames(tracks.(C{ii})); 
    for jj = 1:length(S) % for serie...
        T = fieldnames(tracks.(C{ii}).(S{jj}).scaled);
        for kk = 1:length(T)
            
            tic
    
            bar4 = waitbar(kk/length(T), bar4, strcat(S{jj},'nº',T{kk})) ;
    		    
            % RMSFalpha calc
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSF_alpha')),...
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSF_R2')),...
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSFCorrelationTime')), ~,~] = ...
                enu.rmsf(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk}), [], []) ;
            
            % Shuffl RMSFalpha calc
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sRMSF_alpha')),~,~,~,~] = ...
                enu.rmsf(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk}), [], []) ;
                   
            % DFAgamma calc
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'DFA_gamma'))] = ...
                enu.DFA_main2(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk}),[], []) ;
    
            % Shuff DFAgamma calc
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sDFA_gamma'))] = ...
                enu.DFA_main2(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk}),[], []) ;
        
            % MSDbeta calc
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'MSD_beta'))] = ...
                enu.msd(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,1), ...
                        tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,2),[]) ;
            
            % Shuffled MSDbeta calc
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sMSD_beta'))] = ...
                enu.msd(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,1), ...
                        tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,2),[]) ;    

            % Approximate entropy (Kolmogorov-Sinai entropy)
            results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'ApEn')) = ...
                enu.ApEn(2, 0.2*std(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk})), ...
                         tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk})) ;
    
            % Shuffled Approximate entropy (Kolmogorov-Sinai entropy)
            results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sApEn')) = ...
                enu.ApEn(2, 0.2*std(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk})), ...
                         tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk})) ;
    
            % Intensity of response (mm)
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'Intensity'))] = ...
                norm([tracks.(C{ii}).(S{jj}).scaled.(T{kk})(end,1) tracks.(C{ii}).(S{jj}).scaled.(T{kk})(end,2)]...
                - [tracks.(C{ii}).(S{jj}).scaled.(T{kk})(1,1) tracks.(C{ii}).(S{jj}).scaled.(T{kk})(1,2)]);
    
            % Shuffled intensity of response (mm)
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sIntensity'))] = ...
                norm([tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(end,1) tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(end,2)]...
                - [tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(1,1) tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(1,2)]);
    
            % Directionality ratio (straightness)
            d = hypot(diff(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,1)), diff(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,2))) ;
            distTrav = sum(d);
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'DR'))] = ...
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'Intensity'))/distTrav;
            
            % Shuffled Directionality ratio (straightness)
            d = hypot(diff(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,1)), diff(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,2))) ;
            SdistTrav = sum(d);
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sDR'))] = ...
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sIntensity'))/SdistTrav;
    
            % Average speed (mm/s)
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'AvgSpeed'))] = ...
                distTrav/2050;
    
            % Shuffled average speed (mm/s)
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sAvgSpeed'))] = ...
                SdistTrav/2050;

            %Displacement cosines
            [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'dispCos'))] = ...
                cos(tracks.(C{ii}).(S{jj}).theta.(T{kk})(end));
    
            [C{ii} ' ' S{jj} num2str(kk) ' runtime was ' num2str(toc) ' seconds']
        end
    end

    [C{ii} ' runtime was ' num2str(toc(scenariotime)) ' seconds']

end

%# Save data

['Calculations section runtime FINISHED in ' num2str(toc(tCalcSec)) ' seconds']

save(strcat(destination_folder, '\', run_date ,'_numerical_results.mat'),...
    'tCalcSec', 'results', 'C') ;
