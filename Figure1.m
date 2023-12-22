function Figure1(tracks,folder)

    set(groot,'defaultFigurePaperPositionMode','manual')
    fig = figure('NumberTitle','off','Visible','off','Position',[0 0 1560 1200]);
    
    %% Layouts
    
    layout0 = tiledlayout(fig,2,4,'TileSpacing','compact','Padding','compact') ;
    % layout1 = tiledlayout(layout0,3,1,'TileSpacing','compact','Padding','tight') ;
    % layout1.Layout.Tile = 1;
    % layout1.Layout.TileSpan = [2 1];
    % layout2 = tiledlayout(layout0,3,3,'TileSpacing','none','Padding','tight');
    % layout2.Layout.Tile = 3;
    layouts = {};
    
    %% Panels 1-8
    
    A = {'x_1noStimuli_Cells'
'x_2galvanotaxis_Cells'
'x_3chemotaxis_Cells'
'x_4doubleStimulus_Cells'
'x_1noStimuli_Cytoplasts'
'x_2galvanotaxis_Cytoplasts'
'x_3chemotaxis_Cytoplasts'
'x_4doubleStimulus_Cytoplasts'};
    
    % indexes = {
    % {%No stimulus
    % {1,3,7,8,9,10,11,12,13,14,15,16,18,19,20,24,25,28,33,39}%Proteus
    % {1,4,6,7,9,10,14,16,17,18,20,21,22,23,24,26,27,28,29,31}%Leningradensis
    % {1,2,4,6,12,13,14,15,17,18,20,22,24,27,28,29,30,32,34,35}%Borokensis
    % };
    % {%Galvanotaxis
    % {1,2,3,4,5,7,8,11,14,15,16,17,19,21,22,23,24,25,26,27}%Proteus
    % {1:20}%Leningradensis
    % {1:20}%Borokensis
    % };
    % {%Chemotaxis
    % {2,3,5,6,7,13,14,16,17,18,19,20,21,22,25,26,27,28,29,38}%Proteus
    % {1,2,3,4,6,12,14,18,19,20,21,22,23,26,27,28,29,42,45,59}%Leningradensis
    % {8,9,11,13,15,19,22,25,29,31,32,33,34,44,45,47,50,51,53,55}%Borokensis
    % };
    % {%Induction
    % {1,4,5,7,8,9,11,16,20,22,24,25,26,28,30,32,33,35,36,70}%Proteus
    % {1,8,18,24,30,38,39,40,41,42,43,44,48,49,50,51,52,53,54,57}%Leningradensis
    % {2,32,37,38,40,42,44,47,50,52,57,59,52,68,69,72,75,76,77,78}%Borokensis
    % }
    % };
    for AA = 1:length(A)
        theta = [];
        layouts{AA} = tiledlayout(layout0,10,1,'TileSpacing','compact','Padding','none');
        layouts{AA}.Layout.Tile = AA;
        % speciesScenarioIdx = find(contains(A,A{AA}));
        ax = nexttile(layouts{AA},[6,1]);
        % for species = [length(speciesScenarioIdx),1,2] % specify plotting zorder
        listx=[];
        %     if species == 1
        %         colr = [0, 0, 0];
        %     elseif species == 2
        %         colr = [1, 0, 0];
        %     elseif species == 3
        %         colr = [0, 0, 1];
        %     end
        B = fieldnames(tracks.(A{AA}));
        for BB = 1:length(B)
            C = fieldnames(tracks.(A{AA}).(B{BB}));
            for CC = 1:length(C)
                theta = [theta tracks.(A{AA}).(B{BB}).(C{CC}).theta(end)];
                %# Plot trajectory and a 'ko' marker at its tip      
                plot(tracks.(A{AA}).(B{BB}).(C{CC}).scaled(:,1), ...
                    tracks.(A{AA}).(B{BB}).(C{CC}).scaled(:,2),'Color','k') ;
                hold on;
                plot(tracks.(A{AA}).(B{BB}).(C{CC}).scaled(end,1), ...
                    tracks.(A{AA}).(B{BB}).(C{CC}).scaled(end,2),...
                    'ko', 'Markerfacecolor','k','MarkerSize', 1.75) ;
    %             rng('default')
                listx = [listx tracks.(A{AA}).(B{BB}).(C{CC}).original(end,1)...
                    - tracks.(A{AA}).(B{BB}).(C{CC}).original(1,1)];
            end
        end

        if AA ~= 1 && AA ~= 5 % no-stimuli panels show no left-right percentages
            text(ax,.15, .18,...
                [num2str(round((sum(listx<0)/length(listx))*100)),'%'],...
                'Units','normalized','HorizontalAlignment','center','FontSize',8)
            text(ax,.85, .18,...
                [num2str(round((sum(listx>0)/length(listx))*100)),'%'],...
                'Units','normalized','HorizontalAlignment','center','FontSize',8)
        end
        axis padded
        axis square
        text(ax,.05,.88,["N=50","t=30'"],'Units','normalized',...
            'HorizontalAlignment','left','FontSize',8)
        ax.FontSize = 6;
        MaxX = max(abs(ax.XLim));    MaxY = max(abs(ax.YLim));
        % Add x-line
        x = 0; 
        xl = plot([x,x],ylim(ax), 'k-', 'LineWidth', .5);
        % Add y-line
        y = 0; 
        yl = plot(xlim(ax), [y, y], 'k-', 'LineWidth', .5);
        % Send x and y lines to the bottom of the stack
        uistack([xl,yl],'bottom')
        % Update the x and y line bounds any time the axes limits change
        ax.XAxis.LimitsChangedFcn = @(ruler,~)set(xl, 'YData', ylim(ancestor(ruler,'axes')));
        ax.YAxis.LimitsChangedFcn = @(ruler,~)set(yl, 'XData', xlim(ancestor(ruler,'axes')));
        if MaxX > MaxY
            axis([-MaxX MaxX -MaxY*(MaxX/MaxY) MaxY*(MaxX/MaxY)]);
        elseif MaxY > MaxX
            axis([-MaxX*(MaxY/MaxX) MaxX*(MaxY/MaxX) -MaxY MaxY]);
        elseif MaxY == MaxX
            axis([-MaxX MaxX -MaxY MaxY]);
        end
        % cn=0;
        % for sp = 1:3
        %     if sp == 1
        %         colr = [0, 0, 0];
        %     elseif sp == 2
        %         colr = [1, 0, 0];
        %     elseif sp == 3
        %         colr = [0, 0, 1];
        %     end
            
        if AA == 1 || AA == 5
            pax = polaraxes(layouts{AA});
            pax.Layout.Tile = 7; %Initialize tile
            pax.Layout.TileSpan = [4 1];
            thetaIn360 = mod(theta + 2*pi, 2*pi);
            pol = polarhistogram(pax,thetaIn360,'Normalization','probability','LineWidth',1,...
                'FaceColor','None','DisplayStyle','bar','BinEdges',linspace(-pi, pi, 9));
            % rlim([0 .19])
            x = pol.BinEdges ;
            y = pol.Values ;
            text(pax,x(1:end-1)+pi/9,zeros(length(y),1) + .1,...
                strcat(num2str(round(y'*100,1)),'%'),'vert','bottom','horiz',...
                'center','FontSize',7); %Add labels as percentages
            pax.RTickLabel = [];
            pax.ThetaTickLabel = [];
            pax.RGrid='off';
            thetaticks(0:45:360)
            pax.GridAlpha = 0;
            pax.LineWidth=.05;
            % rticks([])            
            % thetaticks([])
            % thetaticklabels([])
        else
            axh = nexttile(layouts{AA},7,[3,1]); %Initialize tile
            b = histogram(axh,cos(theta),10,"BinEdges",-1:.2:1,'FaceColor','k');
            xticks([-1 0 1])
            xlim([-1,1])
            yticks([min(b.Values) max(b.Values)])
            ylim([0 max(b.Values)])
            axh.FontSize = 6;
            pbaspect([1.28 1 1])
            % axis square
        end
        % cn=cn+1;
        % end
    end
    
    % %% Panel 5
    % 
    % ax1 = nexttile(layout2,[3 3]);
    % 
    % % import and plot trajectory
    % original_x = readmatrix('C:\Users\pc\Desktop\Doctorado\Papers publicados\mov_sist\Tracking panel E fig1.xlsx', "Range", "A:A");
    % original_y = readmatrix('C:\Users\pc\Desktop\Doctorado\Papers publicados\mov_sist\Tracking panel E fig1.xlsx', "Range", "B:B");
    % 
    % % Do not center this trajectory
    % scaled_x = original_x/11.63;
    % scaled_y = original_y/11.63;
    % 
    % plot(scaled_x, scaled_y, 'Color', 'b') ;
    % 
    % ax1.FontSize = 13;
    % xlabel('x(mm)','FontSize',17)
    % ylabel('y(mm)','FontSize',17)
    % ax1.XAxis.TickLength = [0 0];
    % ax1.YAxis.TickLength = [0 0];
    % axis image
    % axis padded
    % 
    % % Define bounds of the first rectangle
    % left = 20.4;
    % bottom = 15.4;
    % width = 0.2;
    % height = 0.23;
    % 
    % % Display the first rectangle
    % hold(ax1,'on');
    % rectangle('Position',[left bottom width height], ...
    %     'EdgeColor','red','LineWidth',0.75);
    % 
    % % Create first axes for zoomed-in view
    % ax2 = axes(layout2);
    % ax2.Layout.Tile = 1;
    % plot(scaled_x, scaled_y, 'Color', 'b')
    % 
    % % Adjust first axis limits and remove ticks
    % axis padded
    % axis equal
    % ax2.XLim = [left left+width];
    % ax2.YLim = [bottom bottom+height];
    % ax2.XAxis.TickLength = [0 0];
    % ax2.YAxis.TickLength = [0 0];
    % 
    % % Set other properties on the first axes
    % ax2.Box = 'on';
    % ax2.XAxis.Color = 'k';
    % ax2.YAxis.Color = 'k';
    % ax2.FontSize = 6;
    % xlabel('x(mm)','FontSize',7)
    % ylabel('y(mm)','FontSize',7)
    % 
    % % Define bounds of the second rectangle
    % left = 20.422;
    % bottom = 15.54;
    % width = .07;
    % height = .08;
    % 
    % % Display the second rectangle
    % hold(ax2,'on');
    % rectangle('Position',[left bottom width height], ...
    %     'EdgeColor','red','LineWidth',0.5);
    % 
    % % Create second axes for zoomed-in view
    % ax3 = axes(layout2);
    % ax3.Layout.Tile = 7;
    % plot(scaled_x, scaled_y, 'Color', 'b')
    % 
    % % Adjust second axis limits and remove ticks
    % axis image
    % axis padded
    % ax3.XLim = [left left+width];
    % ax3.YLim = [bottom bottom+height];
    % ax3.XAxis.TickLength = [0 0];
    % ax3.YAxis.TickLength = [0 0];
    % 
    % % Set other properties on the second axes
    % ax3.Box = 'on';
    % ax3.XAxis.Color = 'k';
    % ax3.YAxis.Color = 'k';
    % ax3.FontSize = 6;
    % xlabel('x(mm)','FontSize',7)
    % ylabel('y(mm)','FontSize',7)
    
    
    
    
    %% Export as jpg, tiff and vector graphics pdf
    
    if ~exist(strcat(folder,'\Figures'), 'dir')
       mkdir(strcat(folder,'\Figures'))
    end
    
    versions = dir(strcat(folder,'\Figures\')) ;
    gabs = 1 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Fig1'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs-1),' Fig1 files found'))
    
    print(fig,'-vector','-dsvg',[folder '\Figures\Fig1(',num2str(gabs),')' '.svg'])
    print(fig,'-image','-djpeg',[folder '\Figures\Fig1(',num2str(gabs),')' '.jpg'])

end
