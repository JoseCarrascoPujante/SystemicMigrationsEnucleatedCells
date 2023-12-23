function Figure2(tracks,T)
    
    figure('Visible','on','Position',[0 0 1250 580]);
    layout0 = tiledlayout(1,3,'TileSpacing','loose','Padding','tight') ;
    layout1 = tiledlayout(layout0,2,1,'TileSpacing','loose','Padding','none') ;
    layout1.Layout.Tile = 1;
    layout1_1 = tiledlayout(layout1,2,2,'TileSpacing','none','Padding','none') ;
    layout1_1.Layout.Tile = 1;
    layout1_2 = tiledlayout(layout1,2,2,'TileSpacing','none','Padding','none') ;
    layout1_2.Layout.Tile = 2;        
    layout2 = tiledlayout(layout0,16,1,'TileSpacing','loose','Padding','none') ;
    layout2.Layout.Tile = 2;
    layout3 = tiledlayout(layout0,2,1,'TileSpacing','tight','Padding','none') ;
    layout3.Layout.Tile = 3;
    
    %% Panel 1 - RMSF max_correlations
    
    % plot one cell rmsf for each scenario
    nexttile(layout1_1)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_1noStimuli_Cells.x06_02_2303_02.x2.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"No stimuli","FontWeight","normal")
    
    % plot one cytoplast rmsf for each scenario
    nexttile(layout1_2)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_1noStimuli_Cytoplasts.x10_12_2218_56.x3.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"No stimuli","FontWeight","normal")
    
    %% Panel 2 - RMSF \alpha
    
    field_names = {
    'x_1noStimuli_Cells'
    'x_2galvanotaxis_Cells'
    'x_3chemotaxis_Cells'
    'x_4doubleStimulus_Cells'
    'x_1noStimuli_Cytoplasts'
    'x_2galvanotaxis_Cytoplasts'
    'x_3chemotaxis_Cytoplasts'
    'x_4doubleStimulus_Cytoplasts'};
    
    tile = 0;
    for f = 1:length(field_names)
        
        tile = tile+1;
        t = nexttile(layout2,tile);
        hold on
        plot(table2array(T(contains(T{:,1},field_names{f}),'RMSF_alpha')),zeros(50), ...
            'ro','MarkerSize',7,'LineWidth',0.25)
        ylim([0 eps]) % minimize y-axis height
        xlim([.5 1])
        t.XRuler.TickLabelGapOffset = 2;
        t.YAxis.Visible = 'off'; % hide y-axis
        t.Color = 'None';
        hold off

        tile=tile+1;
        t2 = nexttile(layout2,tile);
        hold on
        datamean = mean(table2array(T(contains(T{:,1},field_names{f}),'RMSF_alpha')));
        datastd = std(table2array(T(contains(T{:,1},field_names{f}),'RMSF_alpha')));

        line([datamean-datastd datamean+datastd],[0 0],'Color','red',...
            'LineWidth',.5)
        line([datamean-datastd+.001 datamean-datastd],[0 0],'Color','red',...
            'LineWidth',5)
        line([datamean+datastd datamean+datastd+.001],[0 0],'Color','red',...
            'LineWidth',5)
        text(t2,datamean,-.75,[num2str(round(datamean,2)) ' ' char(177) ' '...
            num2str(round(datastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")
        ylim([-0.08 0]) % minimize y-axis height
        xlim([.5 1])
        t2.XRuler.TickLabelGapOffset = 2;
        t2.YAxis.Visible = 'off'; % hide y-axis
        t2.XAxis.Visible = 'off'; % hide y-axis
        t2.Color = 'None';
        hold off
    end
    
    %% Panel 3 - RMSF Violin plots
    ax=nexttile(layout3);
    memory = {}; % one cell array per condition and one array per scenario

    for ii=1:length(field_names)
        memory{ii}=table2array(T(contains(T{:,1},field_names{ii}),'RMSFCorrelationTime'))/120;
    end
       
    enu.superviolin(memory(1:4),'Parent',ax,'Xposition',1,'FaceAlpha',0.15,...
        'Errorbars','ci','Centrals','mean','LineWidth',0.1)

    colorgroups = [ones(length(memory{1}{1}),1);
        repmat(2,length(memory{1}{2}),1);
        repmat(3,length(memory{1}{3}),1);
        repmat(4,length(memory{1}{4}),1);
        ones(length(memory{2}{1}),1);
        repmat(2,length(memory{2}{2}),1);
        repmat(3,length(memory{2}{3}),1);
        repmat(4,length(memory{2}{4}),1);
        ones(length(memory{3}{1}),1);
        repmat(2,length(memory{3}{2}),1);
        repmat(3,length(memory{3}{3}),1);
        repmat(4,length(memory{3}{4}),1)];
    
    rmsfs = {[],[],[]};
    for ii=1:length(conditions) % species    
        for f = find(contains(field_names(:), conditions(ii)))' % conditions
            rmsfs{ii} = [rmsfs{ii}; results.(field_names{f})(:,5)/120];
        end
    end
    
    boxChart_rmsf = cat(1, rmsfs{1}, rmsfs{2}, rmsfs{3});
    boxchart([ones(length(rmsfs{1}), 1); repmat(2, length(rmsfs{2}), 1); ...
        repmat(3, length(rmsfs{3}), 1)], boxChart_rmsf, 'Notch', 'off',...
        'GroupByColor', colorgroups, 'BoxFaceAlpha',0) %Box charts whose notches do not overlap have different medians at the 5% significance level.
    h=gca;
    xlim([.5 3.5])
    ylim([0 20])
    % h.XAxisLocation = 'top';
    box on
    h.XTick = [1 2 3];
    xticklabels(h,[{'\itAmoeba proteus'},{'\itMetamoeba leningradensis'},...
        {'\itAmoeba borokensis'}])
    h.XAxis.FontSize = 16;
    h.XAxis.TickLength = [0 0];
    ylabel('Memory persistence (min)')
    
    
    
    %% Export figures as jpg and svg
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
       mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs = 0 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Fig2'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs),' Fig2 files found'))
    
    % Save the remaining figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure') ;
    for iFig = length(FigList):-1:1
        FigHandle = FigList(iFig) ;
        FigName = get(FigHandle, 'Name') ;
        set(0, 'CurrentFigure', FigHandle) ;
        FigHandle.Units = 'centimeters';                % set figure units to cm
        FigHandle.PaperUnits = 'centimeters';           % set pdf printing paper units to cm
        FigHandle.PaperSize = FigHandle.Position(3:4);  % assign to the printing paper the size of the figure
        FigHandle.PaperPosition = [0 0 FigHandle.Position(3:4)];
        set(FigHandle, 'Renderer', 'painters');
        saveas(FigHandle,strcat(destination_folder, '\Figures\Fig2(',num2str(iFig+gabs),')'),'svg')
    end
end