function imageJ_emu(tracks)
% Plot tracks on top of original video    

% Create ui elements
    fig = uifigure('Position', [0 0 1200 700]);
    g = uigridlayout(fig);
    g.Padding = [5 5 5 5]; % Reduce padding to 5 pixels on all sides
    g.RowHeight = {200,22,22,'1x'};
    g.ColumnWidth = {350,'1x'};
    g.ColumnSpacing = 5; % Reduce column spacing to 5 pixels
    g.RowSpacing = 5; % Reduce row spacing to 5 pixels
    
    slider = uislider(g, 'Orientation','vertical','Value', 1);
    slider.Layout.Row = 4;
    slider.Layout.Column = 1;

    displaycurrentframeButton = uibutton('state','Parent',g,'Text','Slider position', ...
        'ValueChangedFcn',@(src,event) stateButtonClicked(src,event,slider));
    displaycurrentframeButton.Layout.Row = 3;
    displaycurrentframeButton.Layout.Column = 1;
    ax = uiaxes(g);
    ax.Layout.Row = [1 4];
    ax.Layout.Column = 2;
    hold(ax, "on")    
    
    displaycurrentcoordsbutton = uibutton('state','Parent',g,'Text','Mouse coords');
    displaycurrentcoordsbutton.Layout.Row = 2;
    displaycurrentcoordsbutton.Layout.Column = 1;

    % set up callbacks for figure
    fig.WindowButtonMotionFcn = {@mouseMove,ax,displaycurrentcoordsbutton};
    % fig.WindowButtonDownFcn = @stopTracking;

    % Listbox to choose scenario->experiment->track to plot
    trackList = {};
    trackList = enu.unfold(tracks,'tracks',false,trackList);
    trackList = trackList(contains(trackList,'original'));
    myCoords = cell(1,numel(trackList));
    for v = 1:length(trackList)
        myCoords{v} = eval(trackList{v});
    end
    
    lb = uilistbox(g,'Items',cellfun(@(S) S(11:end), trackList, 'Uniform', 0),...
        'ItemsData',myCoords,'FontSize',12,'ValueChangedFcn',@listBox);
    lb.Layout.Row = 1;
    lb.Layout.Column = 1;
    [pc,pf,pm] = deal('');

    function listBox(src,event)
        [~,w,~] = fileparts(string(lb.Items(event.PreviousValueIndex)));        
        [~,y,~] = fileparts(string(lb.Items(lb.ValueIndex)));
        if y ~= w
            % disp(y)
            [hImage,framestack] = loadExp;
            [pc,pf,pm] = plotData(pc,pf,pm); % Plot track        
            set(slider,'UserData',framestack, 'Limits', [1 length(lb.Value)], ...
                'Value', 1, 'MajorTicks', 1:100:length(lb.Value),'ValueChangingFcn', ...
                @(src,event) updateImage(src,event,displaycurrentframeButton,hImage,pm,lb.Value(:,1),lb.Value(:,2)))            
            setup_scroll_wheel(slider,displaycurrentframeButton,hImage,pm, ...
                src.Value(:,1),src.Value(:,2))
        else
            [pc,pf,pm] = plotData(pc,pf,pm); % Plot track
            set(slider, 'Limits', [1 length(lb.Value)], 'Value', 1, 'MajorTicks', 1:100:length(lb.Value))
        end
    end

    function [pc,pf,pm] = plotData(pc,pf,pm)
        switch all(arrayfun(@isempty, [pc,pf,pm]))
            case 1
                % Plot track, pointer & text
                pc = plot(ax,lb.Value(:,1), lb.Value(:,2),'Color','r');                
                pf = plot(ax,lb.Value(end,1), lb.Value(end,2), ...
                    'pentagram','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize', 3.5);             
                pm = plot(ax,lb.Value(1,1), lb.Value(1,2),'o','MarkerFaceColor', ...
                    'none','MarkerEdgeColor','g','MarkerSize', 8);                
            case 0
                pc.XData = lb.Value(:,1);
                pc.YData = lb.Value(:,2);
                pf.XData = lb.Value(end,1);
                pf.YData = lb.Value(end,2);
                pm.XData = lb.Value(1,1);
                pm.YData = lb.Value(1,2);
        end
    end
    
    function [hImage,framestack] = loadExp
        [~,videoName,~] = fileparts(char(lb.Items(lb.ValueIndex)));
        frameDir = uigetdir('C:\Users\JoseC\Desktop\Doctorado\Publicaciones\Papers sin nucleo\frames', ...
            sprintf('Please retrieve %s frames', videoName));
        frameList = extractfield(dir(strcat(frameDir,'\*.jpg')),'name') ;
        nframes = numel(frameList) ;
        % experimentName = strsplit(frameDir,'\');
        % bar1 = waitbar(0,'1','Name',sprintf('Loading %s',string(experimentName(11))));
            % 'Units', 'Normalized', 'Position', [0.1 0.25 0.8 0.25]);
        % tmp = findall(bar1);
        % set(tmp(2), 'Units', 'Normalized', 'Position', [0.1 0.3 0.8 0.2])
        % set(tmp(4), 'Units', 'Normalized', 'Position', [0.1 0.3 0.8 0.25])        
        framestack = cell(1,nframes);
        tic
        for n=1:nframes            
            % waitbar(n/nframes,bar1,sprintf('%1d/%1d',n,nframes)) % Update waitbar
            framestack{n} = rgb2gray(imread(string(strcat(frameDir,'\',frameList(n))))) ;
        end
        fprintf('%s elapsed time = %.2f seconds.\n', videoName, toc);
        % close(bar1)
        sound(sin(1:8000));
        delete(findall(ax.Children, 'type', 'Image'))
        hImage=imshow(framestack{1},'Parent',ax);
        uistack(hImage,'bottom')
    end
    
    function setup_scroll_wheel(slider,~,hImage,pm,~,~)
        set(fig, 'WindowScrollWheelFcn', @(src,event) ...
            scroll_wheel_callback(src,event,slider,displaycurrentframeButton,hImage,pm,lb.Value(:,1),lb.Value(:,2)))
    end
    
    function scroll_wheel_callback(~,event,slider,dispframeButton,hImage,pm,coordsX,coordsY)
        current_slider_value = round(slider.Value);
        if event.VerticalScrollCount < 0
            current_slider_value = current_slider_value - event.VerticalScrollAmount*10;
        elseif event.VerticalScrollCount > 0
            current_slider_value = current_slider_value + event.VerticalScrollAmount*10;
        end
        if (slider.Limits(1) <= current_slider_value) && (current_slider_value <= slider.Limits(2))
            set(slider, 'Value', current_slider_value);
            hImage.CData = slider.UserData{current_slider_value}(:,:);
            if current_slider_value <= length(coordsX)
                pm.XData = coordsX(current_slider_value);
                pm.YData = coordsY(current_slider_value);
            end
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
            src.Text = num2str(round(slider.Value));
        end
    end

    function mouseMove(~,~,ax,coordsbutton)
        % get x and y position of cursor
        xPos = ax.CurrentPoint(1,1);
        yPos = ax.CurrentPoint(1,2);
        % display coordinates in textbox
        if coordsbutton.Value == 1
            coordsbutton.Text = "x: "+xPos+" y: "+yPos;
        end    
    end
    % function stopTracking(f,~)
    %     % stop callback to mouseMove
    %     f.WindowButtonMotionFcn = "";
    % end

end