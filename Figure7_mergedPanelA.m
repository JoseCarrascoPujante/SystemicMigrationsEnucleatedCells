function Figure7_mergedPanelA(tracks,T,destination_folder)
    %% Layouts
    fig = figure('Visible','off','Position',[0 0 1150 800]);
    layout0 = tiledlayout(2,1,'TileSpacing','compact','Padding','none') ;
    layout1 = tiledlayout(layout0,1,2,'TileSpacing','compact','Padding','none') ;
    layout1.Layout.Tile = 1;
    layout2 = tiledlayout(layout1,2,1,'TileSpacing','compact','Padding','none') ;
    layout2.Layout.Tile = 1;
    layout3 = tiledlayout(layout1,16,1,'TileSpacing','tight','Padding','none') ;
    layout3.Layout.Tile = 2;
    layout4 = tiledlayout(layout0,2,1,'TileSpacing','none','Padding','none') ;
    layout4.Layout.Tile = 2;
    
    %% Panel 1 - DFA correlations

    nexttile(layout2,1)
    box on
    dfahandle = gca;
    gamma = enu.DFA_main2(tracks.x_1noStimuli_Cells.x21_11_2211_11.x2.scaled_rho,'original', dfahandle) ;
    yl = ylim();
    xl = xlim();
    text(xl(1)+1,yl(1)+.65,strcat('\gamma=',num2str(round(gamma,2))),"FontSize",10)
    gamma = enu.DFA_main2(tracks.x_1noStimuli_Cytoplasts.x12_12_2215_05.x3.shuffled_rho,'shuffled', dfahandle) ;
    yl = ylim();
    xl = xlim();
    text(xl(1)+1,yl(1)+.25,strcat('\gamma=',num2str(round(gamma,2))),"FontSize",10)    
    axis padded
    
    nexttile(layout2,2)
    box on
    dfahandle = gca;
    gamma = enu.DFA_main2(tracks.x_1noStimuli_Cytoplasts.x12_12_2215_05.x3.scaled_rho,'original', dfahandle) ;
    yl = ylim();
    xl = xlim();
    text(xl(1)+1,yl(1)+.25,strcat('\gamma=',num2str(round(gamma,2))),"FontSize",10)
    axis padded    
    gamma = enu.DFA_main2(tracks.x_1noStimuli_Cells.x21_11_2211_11.x2.shuffled_rho,'shuffled', dfahandle) ;
    yl = ylim();
    xl = xlim();
    text(xl(1)+1,yl(1)+.25,strcat('\gamma=',num2str(round(gamma,2))),"FontSize",10)
    axis padded
    
    xlabel(layout2,'log10(n)','FontSize',11)
    ylabel(layout2,'log10(F(n))','FontSize',11)

    %% Panel 2 - DFA \gamma original and shuffled
    
    field_names = {
    'x_1noStimuli_Cells'
    'x_2galvanotaxis_Cells'
    'x_3chemotaxis_Cells'
    'x_4doubleStimulus_Cells'
    'x_1noStimuli_Cytoplasts'
    'x_2galvanotaxis_Cytoplasts'
    'x_3chemotaxis_Cytoplasts'
    'x_4doubleStimulus_Cytoplasts'};  

    for f = 1:length(field_names)
        
        t = nexttile(layout3);
        hold on
        plot(table2array(T(contains(T{:,1},field_names{f}),'DFA_gamma')),zeros(50), ...
            'ro','MarkerSize',7,'LineWidth',0.3)
        plot(table2array(T(contains(T{:,1},field_names{f}),'sDFA_gamma')),zeros(50), ...
            'o','MarkerEdgeColor','blue','MarkerSize',7,'LineWidth',0.3)        
        ylim([0 eps]) % minimize y-axis height
        xlim([0 2])
        t.XRuler.TickLabelGapOffset = 2.5;
        t.TickLength = [.006 .01];
        t.LineWidth = .25;
        t.FontSize = 8;
        t.YAxis.Visible = 'off'; % hide y-axis
        t.Color = 'None';
        % title(t,scenario(f),'FontSize',11,'FontWeight','normal','Interpreter','none', ...
            % 'VerticalAlignment','bottom')
        hold off

        t2 = nexttile(layout3);
        hold on
        datamean = mean(table2array(T(contains(T{:,1},field_names{f}),'DFA_gamma')));
        datastd = std(table2array(T(contains(T{:,1},field_names{f}),'DFA_gamma')));
        sdatamean = mean(table2array(T(contains(T{:,1},field_names{f}),'sDFA_gamma')));
        sdatastd = std(table2array(T(contains(T{:,1},field_names{f}),'sDFA_gamma')));        

        line([datamean-datastd datamean+datastd],[0 0],'Color','red',...
            'LineWidth',.5)
        line([datamean-datastd+.002 datamean-datastd],[0 0],'Color','red',...
            'LineWidth',5)
        line([datamean+datastd datamean+datastd+.002],[0 0],'Color','red',...
            'LineWidth',5)
        text(t2,datamean,-.2,[num2str(round(datamean,2)) ' ' char(177) ' '...
            num2str(round(datastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")

        line([sdatamean-sdatastd sdatamean+sdatastd],[0 0],'Color','blue',...
            'LineWidth',.5)
        line([sdatamean-sdatastd+.002 sdatamean-sdatastd],[0 0],'Color','blue',...
            'LineWidth',5)
        line([sdatamean+sdatastd sdatamean+sdatastd+.002],[0 0],'Color','blue',...
            'LineWidth',5)
        text(t2,sdatamean,-.2,[num2str(round(sdatamean,2)) ' ' char(177) ' '...
            num2str(round(sdatastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")        

        ylim([-0.2 0]) % minimize y-axis height
        xlim([0 2])
        t2.YAxis.Visible = 'off'; % hide y-axis
        t2.XAxis.Visible = 'off'; % hide y-axis
        t2.Color = 'None';
        hold off
    end
    
    
    %% Panel 3A - DFA \gamma Violin plots original
      
    h = nexttile(layout4,1);
    colores = [1,0,1; 1,.2,1; 1,.45,1; 1,.65,1; 0,1,1; .2,1,1; .45,1,1; .65,1,1];
    space = 0;
    c = 0;
    conditions = ["Cells" "Cytoplasts"];
    scenarios = ["noStimuli" "galvanotaxis" "chemotaxis" "doubleStimulus"];
    for ii=1:length(conditions)
        for jj = 1:length(scenarios)
            c = c+1;
            enu.al_goodplot(table2array(T(contains(T.(1),scenarios(jj)+'_'+conditions(ii)),"DFA_gamma")), space, [], colores(c,:),'bilateral', [], [], 0);
            if ii == 2 && jj == 1
                space = space + 2.4;
            elseif ii == 2 && jj == 2
                space = space + 2.1;                
            else
                space = space + 1.8;
            end
        end
        space = space + 1;
    end
    xlim([-1.2 15.75])
    xticklabels([])
    h.XAxis.TickLength = [0 0];
    h.YAxis.FontSize = 7;
    ylabel('DFA\gamma','FontSize',11)
    
    %% Panel 3B - DFA \gamma Violin plots shuffled
    
    h = nexttile(layout4,2);
    colores = [.3,0,1; .3,.2,1; .3,.45,1; .3,.65,1; 0,1,.3; .2,1,.3; .45,1,.3; .65,1,.3];
    space = 0;
    c = 0;
    conditions = ["Cells" "Cytoplasts"];
    scenarios = ["noStimuli" "galvanotaxis" "chemotaxis" "doubleStimulus"];
    for ii=1:length(conditions)
        for jj = 1:length(scenarios)
            c = c+1;
            enu.al_goodplot(table2array(T(contains(T.(1),scenarios(jj)+'_'+conditions(ii)),"sDFA_gamma")), space, [], colores(c,:),'bilateral', [], [], 0);
            if ii == 2 && jj == 1
                space = space + 2.4;
            elseif ii == 2 && jj == 2
                space = space + 2.1;
            else
                space = space + 1.8;
            end
        end
        space = space + 1;
    end
    xlim([-1.2 15.75])
    xticklabels([])
    h.XAxis.TickLength = [0 0];
    h.YAxis.FontSize = 7;
    ylabel('DFA\gamma (Shuffled)','FontSize',11)
    
    
    %% Export as jpg, tiff and vector graphics pdf
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
       mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs = 1 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Fig7_PanelsAcombined'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs-1),' Fig7_PanelsAcombined files found'))
    print(fig,'-vector','-dsvg',[destination_folder '\Figures\Fig7_PanelsAcombined(',num2str(gabs),')' '.svg'])
    print(fig,'-image','-djpeg','-r400',[destination_folder '\Figures\Fig7_PanelsAcombined(',num2str(gabs),')' '.jpg'])    

    
end

