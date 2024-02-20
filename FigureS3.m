function FigureS3(destination_folder)
    a = [0 2 5 10 20 30;
        0 0.17712933 0.33438485 0.42744479 0.55394321 0.60063091];
    err=[0 0.01813880 0.05063091 0.09116719 0.12413249 0.11214511];
    errorbar(a(1,:),a(2,:),err,'ko-.','LineWidth',.5,'MarkerFaceColor','c');
    box off
    b=gca;
    b.FontName='Arial';
    b.XAxis.FontSize=9;
    b.YAxis.FontSize=9;
    xlabel('Time (min)','FontName','Arial','FontSize',11)
    ylabel('Fluorescent peptide concentration (\muM)','FontName','Arial','FontSize',11)
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
           mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs = 1 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'FigS3'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs-1),' FigS3 files found'))
    print(gcf,'-vector','-dsvg',[destination_folder '\Figures\FigS3(',num2str(gabs),')' '.svg'])
    print(gcf,'-image','-djpeg','-r400',[destination_folder '\Figures\FigS3(',num2str(gabs),')' '.jpg'])