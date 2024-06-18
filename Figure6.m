function Figure6(AE,destination_folder,rr,T)
    %% Layouts
    
    fig = figure('Visible','off','Position', [0 0 1200 625]);
    layout0 = tiledlayout(2,3,'TileSpacing','compact','Padding','none') ;
    
    %% Panel 1 - ApEn heatmaps
        
    % AE min and max as colormap range limits of
    % non-shuffled heatmaps(upper row)
    Zmin = min([min(min(AE.Cells)),min(min(AE.Cytoplasts))]);
    
    Zmax = max([max(max(AE.Cells)),max(max(AE.Cytoplasts))]);

    % AESh min and max as colormap range limits of shuffled
    % heatmaps (lower row)
    sZmin = min([min(min(AE.sCells)),min(min(AE.sCytoplasts))]);
    
    sZmax = max([max(max(AE.sCells)),max(max(AE.sCytoplasts))]);    
        
    columns = size(AE.Cells,2)-6 ;
    
    % rr = randperm(size(AE.Cells,1));
    % tic
    % rr = 1:200;
    % for ii = 1:100000000 % tarda 7 minutos
    %     rr = enu.Shuffle(rr(:),1);
    % end
    % toc

    nexttile(layout0,1)
    h = gca;
    imagesc(AE.Cells(rr,7:end),'AlphaData',~isnan(AE.Cells(rr,7:end)))
    set(h,'YDir','normal')
    colormap(jet)
    xticklabels(h,{});
    h.XAxis.TickLength = [0 0];
    h.YAxis.FontSize = 8;
    ylabel(h,'Series','FontSize',11);
    set(h, 'Color','k')
    clim([Zmin Zmax])
    title('Cells','FontWeight','normal','FontSize',11,'Interpreter','none')

    nexttile(layout0,2)
    h = gca;
    imagesc(AE.Cytoplasts(rr,7:end),'AlphaData',~isnan(AE.Cytoplasts(rr,7:end)))
    set(h,'YDir','normal')
    colormap(jet)
    xticklabels(h,{});
    yticklabels(h,{});
    h.XAxis.TickLength = [0 0];
    h.YAxis.TickLength = [0 0];
    set(h, 'Color','k')
    title('Cytoplasts','FontWeight','normal','FontSize',11,'Interpreter','none')
    a=colorbar(h,"FontSize",8);
    clim([Zmin Zmax])
    ylabel(a,'Approximate Entropy','FontSize',11,'Rotation',270);    

    nexttile(layout0,4)
    h = gca;
    imagesc(AE.sCells(rr,7:end),'AlphaData',~isnan(AE.sCells(rr,7:end)))
    set(h,'YDir','normal')
    colormap(jet)
    xticks([1:columns/5:columns,columns])
    xticklabels(h,300:760:4100);
    h.XAxis.FontSize = 8;
    h.YAxis.FontSize = 8;
    clim([sZmin sZmax]);
    ylabel(h,'Series (shuffled)','FontSize',11);
    xlabel(h,'Time(s)','FontSize',11);
    set(h, 'Color','k')

    nexttile(layout0,5)
    h = gca;
    imagesc(AE.sCytoplasts(rr,7:end),'AlphaData',~isnan(AE.sCytoplasts(rr,7:end)))
    set(h,'YDir','normal')
    colormap(jet)
    xticks([1:columns/5:columns,columns])
    xticklabels(h,300:760:4100);
    yticklabels(h,{});
    h.XAxis.FontSize = 8;
    h.YAxis.FontSize = 8;
    h.YAxis.TickLength = [0 0];
    set(h, 'Color','k')
    a=colorbar(h,"FontSize",8);
    clim([sZmin sZmax]); 
    ylabel(a,'Approximate Entropy (shuffled)','FontSize',11,'Rotation',270);
    
    %% Panel 2 - Violin plots
    % manually moving thee violins or canvas in inkscape destroys the violins,
    % always set their x position programmatically
        
    scenarios = ["noStimuli" "galvanotaxis" "chemotaxis" "doubleStimulus"];
    
    h = nexttile(layout0,3);
    colores = [1,0,1; 1,.2,1; 1,.45,1; 1,.65,1];
    space = [0 3.1 5.9 8.1];
    c = 0;
    for jj = 1:4 % boxes (scenarios)
        c = c+1;
        enu.al_goodplot(table2array(T(contains(T.(1),scenarios(jj)+'_Cells'),"ApEn")), space(jj), [], colores(c,:),'bilateral', [], [], 0);
    end
    xticklabels([])
    h.XAxis.TickLength = [0 0];
    h.YAxis.FontSize = 8;
    title(['Sc1    ' 'Sc2    ' 'Sc3    ' 'Sc4    '],'FontWeight','normal','FontSize',11)
    xlabel('Cells','FontSize',11)
    ylabel('Approximate Entropy','FontSize',11)
    axis padded
    ylim([0 .015]) % manually setting limits disables exp scale in axis
    h.YAxis.Exponent = -3;
    
    h = nexttile(layout0,6);
    colores = [0,1,1; .2,1,1; .45,1,1; .65,1,1];
    space = [0 3.1 5.9 8.1];
    c = 0;
    for jj = 1:4 % boxes (scenarios)
        c = c+1;
        enu.al_goodplot(table2array(T(contains(T.(1),scenarios(jj)+'_Cytoplasts'),"ApEn")), space(jj), [], colores(c,:),'bilateral', [], [], 0);
    end
    xticklabels([])
    h.XAxis.TickLength = [0 0];
    h.YAxis.FontSize = 8;
    title(['Sc1    ' 'Sc2    ' 'Sc3    ' 'Sc4    '],'FontWeight','normal','FontSize',11)
    xlabel('Cytoplasts','FontSize',11)
    ylabel('Approximate Entropy','FontSize',11)
    ylim([0 inf]);
    h.YAxis.Exponent = -3;
    axis padded
    
    %% Export as vector graphics svg file
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
       mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs =  1;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Figure6'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs-1),' Figure6 files found'))
    set(fig, 'color','w','InvertHardCopy', 'off');
    print(fig,'-vector','-dsvg',[destination_folder '\Figures\Figure6(',num2str(gabs),')' '.svg'])
    print(fig,'-image','-djpeg','-r400',[destination_folder '\Figures\Figure6(',num2str(gabs),')' '.jpg'])    
    
    run_date = char(datetime('now','Format','yyyy-MM-dd_HH.mm''''ss''''''''')) ;
    save(strcat(destination_folder,'\',run_date,'RandomIndex.mat'), 'rr')

end
