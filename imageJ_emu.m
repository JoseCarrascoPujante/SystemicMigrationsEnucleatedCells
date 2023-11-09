% function imageJ_emu(coordinates)
close all
clear
load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\ParaImagejEmu_2023-11-08_15.03'15''_200000_shuffles\ParaImageJEmu_2023-11-08_15.03'15''_coordinates.mat")
load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\code\framestack1.mat")
TopLevelDir = 'E:\Doctorado\Amebas\Papers enucleadas TODO\frames enucleadas completos\';
fig = figure('Position', [0 0 1200 770]);
f_n = fieldnames(coordinates);
button = '';
Previous = uicontrol('String','Previous','Position',[30 10 90 30]);
Next = uicontrol('String','Next','Position',[130 10 90 30]);

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
            frameList = dir(strcat(conditionDir,chosenFolder,'\*.jpg'));
            nframes = max(size(frameList)) ;
            
            % Preallocate frame number and resolution for importing later
            % firstframe = imread([pwd '\' frameList(i).name]);
            % [rows, columns] = size(firstframe);      
            % framestack = cell(nframes);
            % [framestack{:}] = deal(zeros(rows,columns));
            % Load frames
            % tic
            % for n=1:nframes
            %     framestack{n} = rgb2gray(imread(strcat(conditionDir,chosenFolder,'\',frameList(i).name))) ;
            % end
            % toc
            
            hImage=imshow(framestack{1});
            currentframe = '1';
            t = uicontrol('String',[num2str(currentframe) '/' num2str(nframes)],'Style','text','Position',[50 604 50 15]);
            jSlider = javax.swing.JSlider;
            javacomponent(jSlider,[100 590 900 35]);
            set(jSlider, 'Value', 1, 'Minimum', 1, 'Maximum', nframes, 'MajorTickSpacing', 200, 'PaintLabels', true, 'PaintTicks',true);
            hjSlider = handle(jSlider, 'CallbackProperties');
            set(hjSlider, 'StateChangedCallback', @sliderCallback);
            hold on
            
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
function sliderCallback( slider, hImage, t, nframes, framestack )
    idx = jSlider.getValue ;
    hImage.CData = imshow(framestack{idx});
    t.String = [num2str(idx) '/' num2str(nframes)];
end
% end