function imageJ_emu(coordinates)
    fig = uifigure('Position', [0 0 1100 700]);
    ax = uiaxes(fig,'Position', fig.Position);
    hold(ax, "on")
    f_n = fieldnames(coordinates);
    nframes = 4100;
    
    f = 1; % f usefulSubfolders
    i = 1; % i experiments in usefulSubfolder
    j = 1; % j tracks in experiment
    
    % Create buttons
    uibutton('push','Parent',fig,'Text','Next',...
        'Position',[110 5 90 30],'ButtonPushedFcn', @nextButton);
    uibutton('push','Parent',fig,'Text','Previous',...
        'Position',[10 5 90 30],'ButtonPushedFcn', @prevButton);
    displaycurrentframeButton = uibutton('state','Parent',fig,'Position',[1100 715 80 20]);
    
    % Create slider
    slider = uislider(fig, 'Orientation','vertical','Value', 1,...
        'Position',[1060 30 1 690]);
    
    % Track iteration while loop
    [pc,pf,pm,pt] = deal('');
    while f <= length(f_n)
        i_n = fieldnames(coordinates.(f_n{f}));
        while i <= size(i_n,1)
            while j <= size(coordinates.(f_n{f}).(i_n{i}).original_x,2)
                
                % Plot frames
                [pc,pf,pm,pt] = plotData(pc,pf,pm,pt);
                if exist('hImage','var') == 0
                    [framestack, nframes] = loadExp();
                    hImage=imshow(framestack{1},'Parent',ax);
                    uistack(hImage,'bottom')
                end
                set(slider,'Limits',[1 nframes],'UserData', framestack,...
                    'MajorTicks', 1:200:nframes,'ValueChangingFcn',...
                    @(src,event) updateImage(src,event,displaycurrentframeButton,hImage,pm,coordinates.(f_n{f}).(i_n{i}).original_x{j},coordinates.(f_n{f}).(i_n{i}).original_y{j}))
                
                % Wait for user input
                uiwait(fig)
                                
            end
            i = i + 1;
            j = 1;
            msgbox('Switching to next experiment, load frames:')
            [framestack, nframes] = loadExp();            
        end
        i = 1;
        f = f + 1;
    end
    
    function [pc,pf,pm,pt] = plotData(pc,pf,pm,pt)
        switch all(arrayfun(@isempty, [pc,pf,pm,pt]))
            case 1
                % Plot track, pointer & text
                pc = plot(ax,coordinates.(f_n{f}).(i_n{i}).original_x{j}, ...
                    coordinates.(f_n{f}).(i_n{i}).original_y{j},'Color','r');                
                pf = plot(ax,coordinates.(f_n{f}).(i_n{i}).original_x{j}(end), ...
                    coordinates.(f_n{f}).(i_n{i}).original_y{j}(end), ...
                    'pentagram','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize', 3.5);             
                pm = plot(ax,coordinates.(f_n{f}).(i_n{i}).original_x{j}(1), ...
                    coordinates.(f_n{f}).(i_n{i}).original_y{j}(1), ...
                    'o','MarkerFaceColor','none','MarkerEdgeColor','g','MarkerSize', 8);                
                pt = text(ax,.05,.97,[f_n{f} ' ' i_n{i} ' nº' num2str(j)], ...
                    'Units','normalized','Interpreter','none','Color','m','FontSize',16);
            case 0
                pc.XData = coordinates.(f_n{f}).(i_n{i}).original_x{j};
                pc.YData = coordinates.(f_n{f}).(i_n{i}).original_y{j};
                pf.XData = coordinates.(f_n{f}).(i_n{i}).original_x{j}(end);
                pf.YData = coordinates.(f_n{f}).(i_n{i}).original_y{j}(end);
                pm.XData = coordinates.(f_n{f}).(i_n{i}).original_x{j}(1);
                pm.YData = coordinates.(f_n{f}).(i_n{i}).original_y{j}(1);
                pt.String = [f_n{f} ' ' i_n{i} ' nº' num2str(j)];
        end
    end

    function nextButton(src,~)
        j = j + 1;
        uiresume(fig)
    end
    
    function prevButton(src,~)
        if (j ~= 1)
            j = j - 1;
        elseif (j == 1) && (i == 1) && (f == 1)
            f = length(f_n);
            i = size (fieldnames(coordinates.(f_n{f})),1);
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2);
        elseif (j == 1) && (i == 1) && (f ~= 1)
            f = f - 1;
            i = size(i_n,1);
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2) ;
            msgbox('Reached first track in this scenario')
        elseif (j == 1) && (i ~= 1) && (f ~= 1)
            i = i - 1;
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2) ;
        end
        uiresume(fig)
    end
    
    function [framestack, nframes] = loadExp()  
        % Get frame dir and N of frames
        frameDir = uigetdir('C:\Users\JoseC\Desktop\Doctorado\Publicaciones\Papers enucleadas\frames para comprobar tracks sinEst,galv,chem');
        frameList = extractfield(dir(strcat(frameDir,'\*.jpg')),'name') ;
        nframes = numel(frameList) ;
        framestack = cell(nframes,1);
        % Load frames
        tic
        for n=1:nframes
            framestack{n} = rgb2gray(imread(string(strcat(frameDir,'\',frameList(n))))) ;
        end
        toc
    end
    
    function updateImage(src,event,dispframeButton,hImage,pm,coordsX,coordsY)
        idx = round(event.Value) ;
        hImage.CData = src.UserData{idx}(:,:);
        pm.XData = coordsX(idx);
        pm.YData = coordsY(idx);
        if dispframeButton.Value == 1
            dispframeButton.Text = num2str(idx);
        end
    end
end