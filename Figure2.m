function Figure2(tracks,T,destination_folder)
    
    figure('Visible','off','Position',[0 0 1400 680]);
    layout0 = tiledlayout(1,3,'TileSpacing','loose','Padding','tight') ;
    layout1 = tiledlayout(layout0,2,1,'TileSpacing','loose','Padding','none') ;
    layout1.Layout.Tile = 1;
    layout1_1 = tiledlayout(layout1,2,2,'TileSpacing','tight','Padding','none') ;
    layout1_1.Layout.Tile = 1;
    layout1_2 = tiledlayout(layout1,2,2,'TileSpacing','tight','Padding','none') ;
    layout1_2.Layout.Tile = 2;        
    layout2 = tiledlayout(layout0,16,1,'TileSpacing','tight','Padding','none') ;
    layout2.Layout.Tile = 2;
    layout3 = tiledlayout(layout0,2,1,'TileSpacing','compact','Padding','none') ;
    layout3.Layout.Tile = 3;
    
    %% Panel 1 - RMSF max_correlations
    
    % plot one cell rmsf for each scenario

    %no stimuli cell
    nexttile(layout1_1)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_1noStimuli_Cells.x24_10_2214_12.x2.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"No stimuli","FontWeight","normal","FontSize",9)

    %galv cell
    nexttile(layout1_1)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_2galvanotaxis_Cells.x05_02_2320_38.x1.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"Galvanotaxis","FontWeight","normal","FontSize",9)

    %chem cell
    nexttile(layout1_1)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_3chemotaxis_Cells.x07_01_2319_49.x3.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"Chemotaxis","FontWeight","normal","FontSize",9)

    %double stimulus cell
    nexttile(layout1_1)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_4doubleStimulus_Cells.x22_01_2318_51.x1.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"Double stimulus","FontWeight","normal","FontSize",9)    
    
    % plot one cytoplast rmsf for each scenario
    %no stimuli cyto
    nexttile(layout1_2)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_1noStimuli_Cytoplasts.x12_12_2216_57.x2.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"No stimuli","FontWeight","normal","FontSize",9)
    
    %galvano cyto
    nexttile(layout1_2)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_2galvanotaxis_Cytoplasts.x30_01_2303_06.x3.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"Galvanotaxis","FontWeight","normal","FontSize",9)

    %chem cyto
    nexttile(layout1_2)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_3chemotaxis_Cytoplasts.x20_12_2214_48.x4.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"Chemotaxis","FontWeight","normal","FontSize",9)

    %double stimulus cyto
    nexttile(layout1_2)
    rmsfhandle = gca;
    enu.rmsf(tracks.x_4doubleStimulus_Cytoplasts.x26_01_2311_04.x2.scaled_rho, rmsfhandle) ;
    title(rmsfhandle,"Double stimulus","FontWeight","normal","FontSize",9)    
    
    %% Panel 2 - RMSFalpha
    
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
            'ro','MarkerSize',7,'LineWidth',0.2)
        ylim([0 eps]) % minimize y-axis height
        xlim([.5 1])
        t.XRuler.TickLabelGapOffset = 2.5;
        t.TickLength = [.006 .01];
        t.LineWidth = .25;
        t.FontSize = 7.5;
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
        text(t2,datamean,-.21,[num2str(round(datamean,2)) ' ' char(177) ' '...
            num2str(round(datastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")
        ylim([-0.2 0]) % minimize y-axis height
        xlim([.5 1])
        t2.YAxis.Visible = 'off'; % hide y-axis
        t2.XAxis.Visible = 'off'; % hide y-axis
        t2.Color = 'None';
        hold off
    end
    
    %% Panel 3 - RMSF Violin plots

    %cells superviolin
    ax=nexttile(layout3);
    memory_violin = {}; % one cell array per condition and one array per scenario

    for ii=1:length(field_names)
        memory_violin{ii}=table2array(T(contains(T{:,1},field_names{ii}),'RMSFCorrelationTime'))/120;
    end
    
    %mejores colormaps: hsv,jet
    enu.superviolin(memory_violin(1:4),'Parent',ax,'FaceAlpha',0.15,...
        'Errorbars','ci','Centrals','mean','LineWidth',0.01,'LUT','hsv')    
    colorgroups = [ones(50,1);repmat(2,50,1);repmat(3,50,1);repmat(4,50,1)];
    boxchart(ax,[ones(200,1)],[cat(1,memory_violin{1:4})], 'Notch', 'off',...
        'GroupByColor', colorgroups, 'BoxFaceAlpha',0,'BoxMedianLineColor','b') %"Box charts whose notches do not overlap have different medians at the 5% significance level".
    colororder(["red" "#00d400" "#0bb" "#800080"]); %select boxplot box colors
    h=gca;
    h.XAxisLocation = 'top';
    h.FontSize = 8;
    box on
    h.XTick = [.84 .94 1.04 1.14];
    xticklabels(h,[{'Sc1'},{'Sc2'},{'Sc3'},{'Sc4'}])
    h.XAxis.FontSize = 10;
    h.XAxis.TickLength = [0 0];
    ylabel('Memory persistence (min)','FontSize',11)
    
    % cytoplasts superviolin
    ax=nexttile(layout3);
    enu.superviolin(memory_violin(5:8),'Parent',ax,'FaceAlpha',0.15,...
    'Errorbars','ci','Centrals','mean','LineWidth',0.01,'LUT','hsv')    
    colorgroups = [ones(50,1);repmat(2,50,1);repmat(3,50,1);repmat(4,50,1)];  
    boxchart(ax,[ones(200,1)],[cat(1,memory_violin{1:4})], 'Notch', 'off',...
        'GroupByColor', colorgroups, 'BoxFaceAlpha',0,'BoxMedianLineColor','b') %"Box charts whose notches do not overlap have different medians at the 5% significance level".
    colororder(["red" "#00d400" "#0bb" "#800080"]); %select boxplot box colors
    h=gca;
    h.XAxisLocation = 'top';
    h.FontSize = 8;
    box on
    h.XTick = [.84 .94 1.04 1.14];
    xticklabels(h,[{'Sc1'},{'Sc2'},{'Sc3'},{'Sc4'}])
    h.XAxis.FontSize = 10;
    h.XAxis.TickLength = [0 0];
    ylabel('Memory persistence (min)','FontSize',11)
    
    
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
        set(0, 'CurrentFigure', FigHandle) ;
        print(FigHandle,'-vector','-dsvg',[destination_folder '\Figures\Fig2(',num2str(gabs),')' '.svg'])
        print(FigHandle,'-image','-djpeg','-r400',[destination_folder '\Figures\Fig2(',num2str(gabs),')' '.jpg'])
    end
end