function Figure3_simple(tracks,T,destination_folder)
    
    figure('Visible','off','Position',[0 0 1400 680]);
    layout0 = tiledlayout(1,3,'TileSpacing','loose','Padding','none') ;
    layout1 = tiledlayout(layout0,2,1,'TileSpacing','loose','Padding','none') ;
    layout1.Layout.Tile = 1;
    % layout1_1 = tiledlayout(layout1,2,2,'TileSpacing','loose','Padding','none') ;
    % layout1_1.Layout.Tile = 1;
    % layout1_2 = tiledlayout(layout1,2,2,'TileSpacing','loose','Padding','none') ;
    % layout1_2.Layout.Tile = 2;        
    layout2 = tiledlayout(layout0,16,1,'TileSpacing','tight','Padding','none') ;
    layout2.Layout.Tile = 2;
    layout3 = tiledlayout(layout0,2,1,'TileSpacing','compact','Padding','none') ;
    layout3.Layout.Tile = 3;
    
    %% Panel 1 - RMSF max_correlations
    
    % plot one cell rmsf for each scenario

    % cell
    nexttile(layout1)
    box on
    rmsfhandle = gca;
    enu.rmsf(tracks.x_1noStimuli_Cells.x24_10_2214_12.x2.scaled_rho, rmsfhandle) ;
    rmsfhandle.FontSize = 7.5;
    title(rmsfhandle,"No stimuli","FontWeight","normal","FontSize",9)

    %cytoplast
    nexttile(layout1)
    box on
    rmsfhandle = gca;
    enu.rmsf(tracks.x_3chemotaxis_Cytoplasts.x20_12_2214_48.x4.scaled_rho, rmsfhandle) ;
    rmsfhandle.FontSize = 7.5;
    title(rmsfhandle,"Chemotaxis","FontWeight","normal","FontSize",9)

    xlabel(layout1,'Log({\itl}(s))',"FontSize",9);
    ylabel(layout1,'Log(F({\itl}))',"FontSize",9);  

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
        % plot(table2array(T(contains(T{:,1},field_names{f}),'sRMSF_alpha')),zeros(50), ...
            % 'o','MarkerEdgeColor','#00c1d4','MarkerSize',7,'LineWidth',0.2)        
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
        % sdatamean = mean(table2array(T(contains(T{:,1},field_names{f}),'sRMSF_alpha')));
        % sdatastd = std(table2array(T(contains(T{:,1},field_names{f}),'sRMSF_alpha')));        

        line([datamean-datastd datamean+datastd],[0 0],'Color','red',...
            'LineWidth',.5)
        line([datamean-datastd+.001 datamean-datastd],[0 0],'Color','red',...
            'LineWidth',5)
        line([datamean+datastd datamean+datastd+.001],[0 0],'Color','red',...
            'LineWidth',5)
        text(t2,datamean,-.1,[num2str(round(datamean,2)) ' ' char(177) ' '...
            num2str(round(datastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")

        % line([sdatamean-sdatastd sdatamean+sdatastd],[0 0],'Color','#00c1d4',...
        %     'LineWidth',.5)
        % line([sdatamean-sdatastd+.001 sdatamean-sdatastd],[0 0],'Color','#00c1d4',...
        %     'LineWidth',5)
        % line([sdatamean+sdatastd sdatamean+sdatastd+.001],[0 0],'Color','#00c1d4',...
        %     'LineWidth',5)
        % text(t2,sdatamean,-.1,[num2str(round(sdatamean,2)) ' ' char(177) ' '...
        %     num2str(round(sdatastd,2))],'HorizontalAlignment','center', ...
        %     'FontSize',9,"FontWeight","normal")        

        ylim([-0.2 0])
        xlim([0.5 1])
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
        'Errorbars','ci','Centrals','mean','LineWidth',.05,'LUT','hsv')    
    colorgroups = [ones(50,1);repmat(2,50,1);repmat(3,50,1);repmat(4,50,1)];
    boxchart(ax,[ones(200,1)],[cat(1,memory_violin{1:4})], 'Notch', 'off',...
        'GroupByColor', colorgroups, 'BoxFaceAlpha',0,'BoxMedianLineColor','b') %"Box charts whose notches do not overlap have different medians at the 5% significance level".
    colororder(["red" "#00d400" "#0bb" "#800080"]); %select boxplot box colors
    h=gca;
    box on
    h.XAxisLocation = 'top';
    xlabel(h,[{'Sc1   '} {'Sc2   '} {'Sc3   '} {'Sc4   '}],'FontSize', 11)
    xticklabels(h,[])
    h.FontSize = 8;
    h.XAxis.TickLength = [0 0];
    ylabel('Memory persistence (min)','FontSize',11)
    
    % cytoplasts superviolin
    ax=nexttile(layout3);
    enu.superviolin(memory_violin(5:8),'Parent',ax,'FaceAlpha',0.15,...
    'Errorbars','ci','Centrals','mean','LineWidth',.05,'LUT','hsv')    
    colorgroups = [ones(50,1);repmat(2,50,1);repmat(3,50,1);repmat(4,50,1)];  
    boxchart(ax,[ones(200,1)],[cat(1,memory_violin{1:4})], 'Notch', 'off',...
        'GroupByColor', colorgroups, 'BoxFaceAlpha',0,'BoxMedianLineColor','b') %"Box charts whose notches do not overlap have different medians at the 5% significance level".
    colororder(["red" "#00d400" "#0bb" "#800080"]); %select boxplot box colors
    h=gca;
    box on
    h.XAxisLocation = 'top';
    xlabel(h,[{'Sc1   '} {'Sc2   '} {'Sc3   '} {'Sc4   '}],'FontSize', 11)
    xticklabels(h,[])
    h.FontSize = 8;
    h.XAxis.TickLength = [0 0];
    ylabel('Memory persistence (min)','FontSize',11)
    
    
    %% Export figures as jpg and svg
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
       mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs = 1 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Fig3_simple'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs-1),' Fig3_simple files found'))
    
    % Save the remaining figures
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure') ;
    for iFig = length(FigList):-1:1
        FigHandle = FigList(iFig) ;
        set(0, 'CurrentFigure', FigHandle) ;
        print(FigHandle,'-vector','-dsvg',[destination_folder '\Figures\Fig3_simple(',num2str(gabs),')' '.svg'])
        print(FigHandle,'-image','-djpeg','-r400',[destination_folder '\Figures\Fig3_simple(',num2str(gabs),')' '.jpg'])
    end
end