%% Figure 3
function Figure3(tracks,T,destination_folder)
    fig=figure('Visible','off','Position',[0 0 1200 640]);
    layout0 = tiledlayout(1,3,'TileSpacing','loose','Padding','tight') ;
    layout1 = tiledlayout(layout0,2,1,'TileSpacing','compact','Padding','none') ;
    layout1.Layout.Tile = 1;
    layout2 = tiledlayout(layout0,16,1,'TileSpacing','tight','Padding','none') ;
    layout2.Layout.Tile = 2;
    layout3 = tiledlayout(layout0,2,1,'TileSpacing','compact','Padding','none') ;
    layout3.Layout.Tile = 3;
    
    %% Panel 1 - MSD \Beta plots
    
    a={};
    a = enu.unfold(tracks,'results',false,a);
    a = a(endsWith(a,'scaled'));
    a = strrep(a,'results','tracks');
    a = [a(contains(a,'x_1noStimuli_Cells')) a(contains(a,'x_1noStimuli_Cytoplasts'))];
    chosen = [2,5,14,34,41,46,48,50;5,6,18,27,32,34,35,49];

    for ii = 1:2
    
        nexttile(layout1,ii)
        h = gca;
        for jj = chosen(ii,:)
            trac = eval(a{jj,ii});
            [~,deltat] = enu.msd(trac(:,1),trac(:,2),h);
        end
        plot(h, log(deltat), log(deltat)-10, 'k--')
        plot(h, log(deltat), log(deltat.^2)-11, 'k--')
        text(h, log(deltat(5)),0,['\beta=2, ballistic' newline 'diffusion']...
            ,'HorizontalAlignment', 'center','FontSize',8)
        text(h, log(deltat(5)),-4.5,'Super-diffusion'...
            ,'HorizontalAlignment', 'center','FontSize',8)
        text(h, log(deltat(5)),-9,['\beta=1, normal' newline 'diffusion']...
            ,'HorizontalAlignment', 'center','FontSize',8)
        h.FontSize = 7.5;
        xlabel('Log(MSD(\tau))','FontSize',10);
        ylabel('Log(\tau(s))','FontSize',10);
        axis padded
        title('Sc1','FontSize',10,'FontWeight','normal')
        
    end
    
    %% Panel 2 - MSD \Beta circles
    
    field_names = {
    'x_1noStimuli_Cells'
    'x_2galvanotaxis_Cells'
    'x_3chemotaxis_Cells'
    'x_4doubleStimulus_Cells'
    'x_1noStimuli_Cytoplasts'
    'x_2galvanotaxis_Cytoplasts'
    'x_3chemotaxis_Cytoplasts'
    'x_4doubleStimulus_Cytoplasts'};  

    % scenario = ["Sc1" "Sc2" "Sc3" "Sc4" "Sc1" "Sc2" "Sc3" "Sc4"];
    
    for f = 1:length(field_names)
        
        t = nexttile(layout2);
        hold on
        plot(table2array(T(contains(T{:,1},field_names{f}),'MSD_beta')),zeros(50), ...
            'ro','MarkerSize',7,'LineWidth',0.3)
        plot(table2array(T(contains(T{:,1},field_names{f}),'sMSD_beta')),zeros(50), ...
            'o','MarkerEdgeColor','#00c1d4','MarkerSize',7,'LineWidth',0.3)        
        ylim([0 eps]) % minimize y-axis height
        xlim([-.1 2.1])
        t.XRuler.TickLabelGapOffset = 2.5;
        t.TickLength = [.006 .01];
        t.LineWidth = .25;
        t.FontSize = 7.5;
        t.YAxis.Visible = 'off'; % hide y-axis
        t.Color = 'None';
        % title(t,scenario(f),'FontSize',10,'FontWeight','normal','Interpreter','none', ...
            % 'VerticalAlignment','bottom')
        hold off

        t2 = nexttile(layout2);
        hold on
        datamean = mean(table2array(T(contains(T{:,1},field_names{f}),'MSD_beta')));
        datastd = std(table2array(T(contains(T{:,1},field_names{f}),'MSD_beta')));
        sdatamean = mean(table2array(T(contains(T{:,1},field_names{f}),'sMSD_beta')));
        sdatastd = std(table2array(T(contains(T{:,1},field_names{f}),'sMSD_beta')));        

        line([datamean-datastd datamean+datastd],[0 0],'Color','red',...
            'LineWidth',.5)
        line([datamean-datastd+.002 datamean-datastd],[0 0],'Color','red',...
            'LineWidth',5)
        line([datamean+datastd datamean+datastd+.002],[0 0],'Color','red',...
            'LineWidth',5)
        text(t2,datamean,-.15,[num2str(round(datamean,2)) ' ' char(177) ' '...
            num2str(round(datastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")

        line([sdatamean-sdatastd sdatamean+sdatastd],[0 0],'Color','#00c1d4',...
            'LineWidth',.5)
        line([sdatamean-sdatastd+.002 sdatamean-sdatastd],[0 0],'Color','#00c1d4',...
            'LineWidth',5)
        line([sdatamean+sdatastd sdatamean+sdatastd+.002],[0 0],'Color','#00c1d4',...
            'LineWidth',5)
        text(t2,sdatamean,-.15,[num2str(round(sdatamean,2)) ' ' char(177) ' '...
            num2str(round(sdatastd,2))],'HorizontalAlignment','center', ...
            'FontSize',9,"FontWeight","normal")        

        ylim([-0.2 0]) % minimize y-axis height
        xlim([-.1 2.1])
        t2.YAxis.Visible = 'off'; % hide y-axis
        t2.XAxis.Visible = 'off'; % hide y-axis
        t2.Color = 'None';
        hold off
    end
    
    
    %% "Superviolin" plots of MSD \beta
    %cells superviolin
    ax=nexttile(layout3);
    memory_violin = {}; % one cell array per condition and one array per scenario

    for ii=1:length(field_names)
        memory_violin{ii}=table2array(T(contains(T{:,1},field_names{ii}),'MSD_beta'));
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
    h.FontSize = 7.5;
    box on
    h.XTick = [.84 .94 1.04 1.14];
    xticklabels(h,[{'Sc1'},{'Sc2'},{'Sc3'},{'Sc4'}])
    h.XAxis.FontSize = 10;
    h.XAxis.TickLength = [0 0];
    ylabel('MSD\beta','FontSize',10)
    
    % cytoplasts superviolin
    ax=nexttile(layout3);
    enu.superviolin(memory_violin(5:8),'Parent',ax,'FaceAlpha',0.15,...
    'Errorbars','ci','Centrals','mean','LineWidth',0.01,'LUT','hsv','Bandwidth',0.3)    
    colorgroups = [ones(50,1);repmat(2,50,1);repmat(3,50,1);repmat(4,50,1)];  
    boxchart(ax,[ones(200,1)],[cat(1,memory_violin{1:4})], 'Notch', 'off',...
        'GroupByColor', colorgroups, 'BoxFaceAlpha',0,'BoxMedianLineColor','b') %"Box charts whose notches do not overlap have different medians at the 5% significance level".
    colororder(["red" "#00d400" "#0bb" "#800080"]); %select boxplot box colors
    h=gca;
    h.XAxisLocation = 'top';
    h.FontSize = 7.5;
    box on
    h.XTick = [.84 .94 1.04 1.14];
    xticklabels(h,[{'Sc1'},{'Sc2'},{'Sc3'},{'Sc4'}])
    h.XAxis.FontSize = 10;
    h.XAxis.TickLength = [0 0];
    ylabel('MSD\beta','FontSize',10)
    
    %% Export as jpg, tiff and vector graphics pdf
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
       mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs = 0 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Fig3'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs),' Fig3 files found'))
    print(fig,'-vector','-dsvg',[destination_folder '\Figures\Fig3(',num2str(gabs),')' '.svg'])
    print(fig,'-image','-djpeg','-r400',[destination_folder '\Figures\Fig3(',num2str(gabs),')' '.jpg'])

end

