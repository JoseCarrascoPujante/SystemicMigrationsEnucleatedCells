% function imageJ_emu(coordinates)
close all
clearvars -except framestack coordinates
% load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\ParaImagejEmu_2023-11-09_02.48'13''_200000_shuffles\ParaImagejEmu_2023-11-09_02.48'13''_coordinates.mat")
% load("C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\mov.sist.enucleadas\sample_framestack.mat")
fig = uifigure('Position', [0 0 1200 750]);
ax = uiaxes(fig,'Position', fig.Position);
f_n = fieldnames(coordinates);

% Create Load frames & Next/Previous track buttons
button = '';
loadFrames = uibutton('push','Parent',fig,'String','Load experiment',...
    'Position',[10 10 90 30],'Callback', @loadExp);
Next = uibutton('push','Parent',fig,'String','Next',...
    'Position',[110 10 90 30],'Callback', @nextButton);
Prev = uibutton('push','Parent',fig,'String','Load experiment',...
    'Position',[210 10 90 30],'Callback', @prevButton);

% Create dispframeButton
dispframeButton = uibutton('state','Parent',fig,'Position',[1100 715 80 20]);

% Create slider
slider = uislider(fig, 'Orientation','vertical','Value', 1,...
                'Position',[1040 30 1 690]);



f = 1; % N usefulSubfolders
i = 1; % N experiments in usefulSubfolder
j = 1; % N tracks in experiment

while f <= length(f_n)
    i_n = fieldnames(coordinates.(f_n{f}));
    while i <= size(i_n,1)
        while j <= size(coordinates.(f_n{f}).(i_n{i}).original_x,2)

            % Plot tracks and pointer

            plot(ax,coordinates.(f_n{f}).(i_n{i}).original_x{j}, ...
                coordinates.(f_n{f}).(i_n{i}).original_y{j},'Color','r')
            plot(ax,coordinates.(f_n{f}).(i_n{i}).original_x{j}(end), ...
                coordinates.(f_n{f}).(i_n{i}).original_y{j}(end),...
                'pentagram','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize', 3)
            hMarker = plot(ax,coordinates.(f_n{f}).(i_n{i}).original_x{j}(1), ...
                coordinates.(f_n{f}).(i_n{j}).original_y{i}(1),...
                'o','MarkerFaceColor','none','MarkerEdgeColor','g','MarkerSize', 8);
            
            text(ax,.05,.96,[f_n{f} ' ' i_n{i} ' nº' num2str(j)],...
                'Units','normalized','Interpreter','none','Color','m','FontSize',16)
            
            % Get frame dir and N of frames
            frameDir = uigetdir('C:\Users\pc\Desktop\Doctorado\Publicaciones\Papers enucleadas\frames para comprobar tracks sinEst,galv,chem\');
            frameList = extractfield(dir(strcat(frameDir,'\*.jpg')),'name') ;
            nframes = numel(frameList) ;
            
            % Load frames
            % framestack = cell(nframes,1);
            % tic
            % for n=1:nframes
            %     framestack{n} = rgb2gray(imread(strcat(frameDir,'\',frameList(n)))) ;
            % end
            % toc
            
            hImage=imshow(framestack{1},'Parent',ax);
            hold(ax, "on")

            set(slider,'Limits',[1 nframes],'UserData', framestack,...
                'MajorTicks', 1:200:nframes)
            
            set(slider,'ValueChangingFcn',...
                @(src,event) updateImage(src,event,dispframeButton,hImage,hMarker,coordinates.(f_n{f}).(i_n{j}).original_x{j},coordinates.(f_n{f}).(i_n{j}).original_y{j}))
            
            % Wait for user input
            uiwait(fig)
            % hold(ax,"off")
            
            
            % if contains(button,'Next')
            %     i = i + 1;
            % elseif contains(button,'Previous')
            %     if (i ~= 1)
            %         i = i - 1;
            %     elseif (i == 1) && (f == 1)
            %         msgbox('First entry of the dataset has been reached')
            %     elseif (i == 1) && (f ~= 1)
            %         f = f - 1;
            %         i = size(coordinates.(f_n{f}).scaled_x,2) ;
            %     end
            % end
        end
    end
    % f = f + 1;
    % i = 1;
end

function loadExp(object,~,fig)

end

function nextButton(object,~,fig)

end

function prevButton(object,~,fig)

end

function updateImage(src,event,dispframeButton,hImage,hMarker,coordsX,coordsY)
    idx = round(event.Value) ;
    hImage.CData = src.UserData{idx}(:,:);
    hMarker.XData = coordsX(idx);
    hMarker.YData = coordsY(idx);
    if dispframeButton.Value == 1
        dispframeButton.Text = num2str(idx);
    end
end

% end