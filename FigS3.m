function FigS3(destination_folder)
    a = [0 2 5 10 20 30;
        0 0.1783 0.398553345 0.52188 0.68318264	0.7473779];
    err=[0 0.018289318 0.0506109578 0.0909735908 0.1240835632 0.1121009065];
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