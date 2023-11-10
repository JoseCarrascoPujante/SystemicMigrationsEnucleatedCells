% function imageJ_emu(coordinates)
close all
clear
load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\ParaImagejEmu_2023-11-09_02.48'13''_200000_shuffles\ParaImagejEmu_2023-11-09_02.48'13''_coordinates.mat")
load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\sample_framestack.mat")
TopLevelDir = 'C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\frames para comprobar tracks sinEst,galv,chem\';
fig = figure('Position', [0 0 1200 750]);
ax = axes('Parent',fig);
f_n = fieldnames(coordinates);
button = '';
Previous = uicontrol('String','Previous','Position',[30 10 90 30]);
Next = uicontrol('String','Next','Position',[130 10 90 30]);
slider = uicontrol('Parent',fig,'Style','slider',...
    'Min',1,'Max',10,'Value',1,'SliderStep',[1/9 1/9],...
    'Position',[100 590 900 35],...
    'Callback',@sliderCallback);

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
            hold on
            set(slider, 'Value', 1,'Min', 1, 'Max', nframes, 'UserData', framestack);
            
            
            % Plot track and pointer
            plot(coordinates.(f_n{f}).(j_n{j}).original_x{j}, ...
                coordinates.(f_n{f}).(j_n{j}).original_y{j},'Color','r')
            plot(coordinates.(f_n{f}).(j_n{j}).original_x{j}(end), ...
                coordinates.(f_n{f}).(j_n{j}).original_y{j}(end),...
                'ko','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize', 2)
            text(.05,.95,[f_n{f} ' ' j_n{j} ' nº' num2str(j)],'Units','normalized','Interpreter','none','Color','m')
            % axis equal
            hold off
            uiwait(fig)
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

function sliderCallback(src, event, ax, nframes)
    idx = round(src.Value) ;
    imageArray = src.UserData ;
    % t.String = [num2str(idx) '/' num2str(nframes)];
    hold on
    o = imshow(imageArray{idx}(:,:),'Parent',src.Parent.Children(4));
    % title(ax, sprintf('%g/%g', idx, nframes));
    uistack(o,'bottom')
end

% function framestack = readFrames(nframes,conditionDir,chosenFolder,frameList)
%     firstframe = rgb2gray(imread(strcat(conditionDir,chosenFolder,'\',frameList(1))));
%     [rows, columns] = size(firstframe);      
%     framestack = cell(nframes,1);
%     [framestack{:}] = deal(zeros(rows,columns));
%     tic
%     parfor n=1:nframes
%         framestack{n}=rgb2gray(imread(strcat(conditionDir,chosenFolder,'\',frameList(n))));
%     end
%     toc
% end

% end