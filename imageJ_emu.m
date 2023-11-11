% function imageJ_emu(coordinates)
close all
clearvars -except framestack coordinates
% load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\ParaImagejEmu_2023-11-09_02.48'13''_200000_shuffles\ParaImagejEmu_2023-11-09_02.48'13''_coordinates.mat")
% load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\sample_framestack.mat")
TopLevelDir = 'C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\frames para comprobar tracks sinEst,galv,chem\';
fig = uifigure('Position', [0 0 1200 750]);
ax = uiaxes(fig,'Position', fig.Position);
f_n = fieldnames(coordinates);

% Create Next and Previous buttons
button = '';
Previous = uicontrol('Parent',fig,'String','Previous','Position',[30 10 90 30]);
Next = uicontrol('Parent',fig,'String','Next','Position',[130 10 90 30]);

% Create frameButton
frameButton = uibutton('state','Parent',fig,'Position',[1100 715 80 20]);

% Create slider
slider = uislider(fig, 'Orientation','vertical','Value', 1,...
                'Position',[1040 30 1 690]);

f = 1; % N of usefulSubfolders
i = 1; % N of experiment in usefulSubfolder
j = 1; % N of tracks in experiment

while f <= length(f_n)
    j_n = fieldnames(coordinates.(f_n{f}));
    while i <= size(j_n,1)
        while j <= size(coordinates.(f_n{f}).(j_n{j}).scaled_x,2)
            Previous.Callback = {@ButtonMode,fig};
            Next.Callback = {@ButtonMode,fig};
            
            %%% Uncomment the following lines to "square up" the plots
            % if MaxX > MaxY 
            %     axis([-MaxX MaxX -MaxY*(MaxX/MaxY) MaxY*(MaxX/MaxY)]);
            % elseif MaxY > MaxX
            %     axis([-MaxX*(MaxY/MaxX) MaxX*(MaxY/MaxX) -MaxY MaxY]);
            % elseif MaxY == MaxX
            %     axis([-MaxX MaxX -MaxY MaxY]);
            % end
    
            % Plot video frames in the background
            scenarioAndCondition = strsplit(f_n{f}, '_');
            conditionDir = string(strcat(TopLevelDir,scenarioAndCondition(1),'\',scenarioAndCondition(2),'\'));
            filelist = dir(conditionDir) ;
            arefolders = [filelist.isdir] ;
            folderlist = extractfield(filelist(arefolders),'name') ;
            bestMatchIdx = strnearest(j_n{j},folderlist);
            chosenFolder = folderlist{bestMatchIdx};
            frameList = extractfield(dir(strcat(conditionDir,chosenFolder,'\*.jpg')),'name');
            nframes = max(size(frameList)) ;
            
            % Load frames
            % framestack = cell(nframes,1);
            % tic
            % for n=1:nframes
            %     framestack{n} = rgb2gray(imread(strcat(conditionDir,chosenFolder,'\',frameList(n)))) ;
            % end
            % toc

            hImage=imshow(framestack{1},'Parent',ax);
            hold(ax, "on")
            
            % Plot track and pointer
            plot(ax,coordinates.(f_n{f}).(j_n{j}).original_x{j}, ...
                coordinates.(f_n{f}).(j_n{j}).original_y{j},'Color','r')
            plot(ax,coordinates.(f_n{f}).(j_n{j}).original_x{j}(end), ...
                coordinates.(f_n{f}).(j_n{j}).original_y{j}(end),...
                'pentagram','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize', 3)
            hMarker = plot(ax,coordinates.(f_n{f}).(j_n{j}).original_x{j}(1), ...
                coordinates.(f_n{f}).(j_n{j}).original_y{j}(1),...
                'o','MarkerFaceColor','none','MarkerEdgeColor','g','MarkerSize', 8);
            text(ax,.05,.96,[f_n{f} ' ' j_n{j} ' nº' num2str(j)],...
                'Units','normalized','Interpreter','none','Color','m','FontSize',16)

            set(slider,'Limits',[1 nframes],'UserData', framestack,...
                'MajorTicks', 1:200:nframes,'ValueChangingFcn',...
                @(src,event) updateImage(src,event,frameButton,hImage,hMarker,coordinates.(f_n{f}).(j_n{j}).original_x{j},coordinates.(f_n{f}).(j_n{j}).original_y{j}));
                %if func and vargin are not defined here I get "not enough input argument" error
            % Wait for user input
            uiwait(fig)
            hold(ax,"off")
            if contains(button,'Next')
                i = i + 1;
            elseif contains(button,'Previous')
                if (i ~= 1)
                    i = i - 1;
                elseif (i == 1) && (f == 1)
                    msgbox('First entry of the dataset has been reached')
                elseif (i == 1) && (f ~= 1)
                    f = f - 1;
                    i = size(coordinates.(f_n{f}).scaled_x,2) ;
                end
            end
        end
    end
    f = f + 1;
    i = 1;
end

function ButtonMode(object,~,fig)
    if strcmpi(object.String, 'Previous')
        button = 'Previous';
        uiresume(fig)
    elseif strcmpi(object.String, 'Next')
        button = 'Next';
        uiresume(fig)
    end
end

function updateImage(src,event,frameButton,hImage,hMarker,coordsX,coordsY)
    idx = round(event.Value) ;
    hImage.CData = src.UserData{idx}(:,:);
    hMarker.XData = coordsX(idx);
    hMarker.YData = coordsY(idx);
    if frameButton.Value == 1
        frameButton.Text = num2str(idx);
    end
end

% end