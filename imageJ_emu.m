function imageJ_emu(coordinates)
    % Create ui elements
    fig = uifigure('Position', [0 0 1200 700]);
    ax = uiaxes(fig,'Position', fig.Position);
    hold(ax, "on")
    slider = uislider(fig, 'Orientation','vertical','Value', 1,...
        'Position',[1135 30 1 690]);
    displaycurrentframeButton = uibutton('state','Parent',fig, ...
        'Position',[1180 650 80 20],'ValueChangedFcn',@(src,event) stateButtonClicked(src,event,slider));
    uibutton('push','Parent',fig,'Text','Load frames',...
        'Position',[1180 600 90 20],'ButtonPushedFcn', @loadframesButton);
    uibutton('push','Parent',fig,'Text','Next',...
        'Position',[110 5 90 30],'ButtonPushedFcn', @nextButton);
    uibutton('push','Parent',fig,'Text','Previous',...
        'Position',[10 5 90 30],'ButtonPushedFcn', @prevButton);    
    
    % Track iteration while loop
    f_n = fieldnames(coordinates);
    
    % Optional dropdown menu to choose scenario->experiment->track to plot
    % dd = uidropdown(fig,'Editable','off','Position',[320 5 200 30],...
    %     'DropDownOpeningFcn',@dropdownUpdate,'ValueChangedFcn',@dropdownPlot);
    
    f = 1; % f scenario
    i = 1; % i experiments in scenario
    j = 1; % j tracks in experiment
    
    [pc,pf,pm,pt] = deal('');
    while (f > 0) && (f <= length(f_n))
        i_n = fieldnames(coordinates.(f_n{f}));        
        while (i > 0) && (i <= size(i_n,1))
            selection = uiconfirm(fig,["Load experiment's" i_n{i} "frames?"],...
                'Confirm import',"Options",["Yes","No"],...
                "DefaultOption",2,"CancelOption",2);
            switch selection
                case 'Yes'
                    [hImage,nframes,framestack] = loadExp;
                case 'No'
            end                                
            
            while (j > 0) && (j <= size(coordinates.(f_n{f}).(i_n{i}).original_x,2))   
                [pc,pf,pm,pt] = plotData(pc,pf,pm,pt); % Plot track
                if exist('hImage','var')
                    setup_scroll_wheel(slider,displaycurrentframeButton,hImage,pm,coordinates.(f_n{f}).(i_n{i}).original_x{j},coordinates.(f_n{f}).(i_n{i}).original_y{j})
                    set(slider,'Limits',[1 nframes],'UserData',framestack,'Value',1,'MajorTicks', 1:200:nframes,...
                        'ValueChangingFcn',@(src,event) updateImage(src,event,displaycurrentframeButton,hImage,pm,coordinates.(f_n{f}).(i_n{i}).original_x{j},coordinates.(f_n{f}).(i_n{i}).original_y{j}))
                end
                uiwait(fig) % Wait for user input
            end
            i = i + 1;
            j = 1;
        end
        i = 1;
        f = f + 1;
    end
    
    function loadframesButton(~,~)
        % choose experiment to display in the background &
        % update slider accordingly
        [hImage,nframes,framestack] = loadExp;
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
                pt = text(ax,.03,1.03,[f_n{f} ' ' i_n{i} ' nº' num2str(j)], ...
                    'Units','normalized','Interpreter','none','Color','k','FontSize',16);
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

    function nextButton(~,~)
        if (f == length(f_n)) && (i == length(i_n)) && (j == size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2))
            f = 1;
            i_n = fieldnames(coordinates.(f_n{f}));
            i = 1;
            j = 1;
        else
            j = j + 1;
        end
        uiresume(fig)
    end
    
    function prevButton(~,~)
        if j ~= 1
            j = j - 1;
        elseif (j == 1) && (i == 1) && (f == 1)
            f = length(f_n);
            i_n = fieldnames(coordinates.(f_n{f}));
            i = length(i_n);
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2);
        elseif (j == 1) && (i == 1) && (f ~= 1)
            f = f - 1;
            i_n = fieldnames(coordinates.(f_n{f}));
            i = length(i_n);
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2) ;
        elseif (j == 1) && (i ~= 1) && (f == 1)
            i = i - 1;
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2) ;
        elseif (j == 1) && (i ~= 1) && (f ~= 1)
            f = f - 1;
            i_n = fieldnames(coordinates.(f_n{f}));
            i = i - 1;
            j = size(coordinates.(f_n{f}).(i_n{i}).scaled_x,2) ;
        end
        uiresume(fig)
    end
    
    function [hImage,nframes,framestack] = loadExp
        frameDir = uigetdir('C:\Users\JoseC\Desktop\Doctorado\Publicaciones\Papers sin nucleo\frames', ...
            ['Please, load ' f_n{f} ' ' i_n{i} ' frames']);
        experimentName = strsplit(frameDir,'\');
        set(fig,'Name',strcat('Frames',string(experimentName(11))))
        bar1 = waitbar(0,'1','Name',sprintf('Loading %s...',string(experimentName(11))), ...
            'Units', 'Normalized', 'Position', [0.1 0.25 0.8 0.25]);
        tmp = findall(bar1);
        set(tmp(2), 'Units', 'Normalized', 'Position', [0.1 0.3 0.8 0.2])
        set(tmp(4), 'Units', 'Normalized', 'Position', [0.1 0.3 0.8 0.25])
        frameList = extractfield(dir(strcat(frameDir,'\*.jpg')),'name') ;
        nframes = numel(frameList) ;
        framestack = cell(1,nframes);
        tic
        for n=1:nframes
            % Update waitbar and message
            waitbar(n/nframes,bar1,sprintf('%1d',n))       
            framestack{n} = rgb2gray(imread(string(strcat(frameDir,'\',frameList(n))))) ;
        end
        toc
        close(bar1)
        hImage=imshow(framestack{1},'Parent',ax);
        uistack(hImage,'bottom')
    end
    
    function setup_scroll_wheel(slider,~,hImage,pm,~,~)
        set(fig, 'WindowScrollWheelFcn', @(src,event) scroll_wheel_callback(src,event,slider,displaycurrentframeButton,hImage,pm,coordinates.(f_n{f}).(i_n{i}).original_x{j},coordinates.(f_n{f}).(i_n{i}).original_y{j}))
    end
    
    function scroll_wheel_callback(~,event,slider,dispframeButton,hImage,pm,coordsX,coordsY)
        current_slider_value = round(slider.Value);
        if event.VerticalScrollCount < 0
            current_slider_value = current_slider_value + event.VerticalScrollAmount*10;
        elseif event.VerticalScrollCount > 0
            current_slider_value = current_slider_value - event.VerticalScrollAmount*10;
        end
        if (slider.Limits(1) <= current_slider_value) && (current_slider_value <= slider.Limits(2))
            set(slider, 'Value', current_slider_value);
            hImage.CData = slider.UserData{current_slider_value}(:,:);
            pm.XData = coordsX(current_slider_value);
            pm.YData = coordsY(current_slider_value);
            if dispframeButton.Value == 1
                dispframeButton.Text = num2str(current_slider_value);
            end
        end
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

    function stateButtonClicked(src,event,slider)
        if event.PreviousValue == 0
            src.Text = num2str(slider.Value);
        end
    end

end