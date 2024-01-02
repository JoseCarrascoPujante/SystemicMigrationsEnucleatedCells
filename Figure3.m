%% Figure 3
function Figure3(tracks,resultados,destination_folder)
    figure('Visible','on','Position',[0 0 1300 640]);
    layout0 = tiledlayout(1,3,'TileSpacing','loose','Padding','tight') ;
    layout1 = tiledlayout(layout0,2,1,'TileSpacing','loose','Padding','none') ;
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

    for ii = 1:length(a)
    
        nexttile(layout1,ii)
        h = gca;
        for jj = chosen(ii,:)
            trac = eval(a{jj,ii});
            [~,deltat] = enu.msd(trac(:,1),trac(:,2),h);
        end
        plot(h, log(deltat), log(deltat)-10, 'k--')
        plot(h, log(deltat), log(deltat.^2)-11, 'k--')
        text(h, log(deltat(5)),0,['\beta=2, ballistic' newline 'diffusion']...
            ,'HorizontalAlignment', 'center','FontSize',10.5)
        text(h, log(deltat(5)),-4.5,'Super-diffusion'...
            ,'HorizontalAlignment', 'center','FontSize',10.5)
        text(h, log(deltat(5)),-9,['\beta=1, normal' newline 'diffusion']...
            ,'HorizontalAlignment', 'center','FontSize',10.5)
        xlabel('Log(MSD(\tau))');
        ylabel('Log(\tau(s))');
        axis padded
        
    end
    
    %% Panel 2 - MSD \Beta circles
    
    field_names = ...
        {'SinEstimuloProteus11_63'
        'GalvanotaxisProteus11_63'
        'QuimiotaxisProteus11_63'
        'InduccionProteus11_63'
        'SinEstimuloLeningradensis11_63'
        'GalvanotaxisLeningradensis11_63'
        'QuimiotaxisLeningradensisVariosPpmm'
        'InduccionLeningradensis11_63'
        'SinEstimuloBorokensis23_44'
        'GalvanotaxisBorokensis11_63'
        'QuimiotaxisBorokensis23_44'
        'InduccionBorokensis11_63'
        };
    
    species = {'Proteus','Leningradensis','Borokensis'};
    tiles = {
    [1,7,13,19;4,10,16,22]
    [2,8,14,20;5,11,17,23]
    [3,9,15,21;6,12,18,24]
    };
    
    for ii = 1:length(species)
        idx = find(contains(field_names(:),species{ii}))';
        for f = 1:length(idx)
            disp(field_names{idx(f)})
            t = nexttile(layout2,tiles{ii}(1,f));
            hold on
            
            exes = zeros(size(resultados.(field_names{idx(f)}),1));
            plot(resultados.(field_names{idx(f)})(:,9),exes,'ro','MarkerSize',7)
            plot(resultados.(field_names{idx(f)})(:,10),exes,'bo','MarkerSize',7)
            ylim([0 eps]) % minimize y-axis height
            xlim([-0.1 2.1])
            t.XRuler.TickLabelGapOffset = 2;
            t.YAxis.Visible = 'off'; % hide y-axis
            t.Color = 'None';
            hold off
    
            t2 = nexttile(layout2,tiles{ii}(2,f));
            hold on
            datamean = mean(resultados.(field_names{idx(f)})(:,9));
            datastd = std(resultados.(field_names{idx(f)})(:,9));
            datameanshuff = mean(resultados.(field_names{idx(f)})(:,10));
            datastdshuff = std(resultados.(field_names{idx(f)})(:,10));
            line([datamean-datastd datamean+datastd],[0 0],'Color','red',...
                'LineWidth',.5)
            line([datamean-datastd+.005 datamean-datastd],[0 0],'Color','red',...
                'LineWidth',5)
            line([datamean+datastd datamean+datastd+.005],[0 0],'Color','red',...
                'LineWidth',5)
            text(t2,datamean,-.075,[num2str(round(datamean,2)) ' ' char(177) ' '...
                num2str(round(datastd,2))],'HorizontalAlignment','center','FontSize',8)
            line([datameanshuff-datastdshuff datameanshuff+datastdshuff],[0 0],'Color','blue',...
                'LineWidth',.5)
            line([datameanshuff-datastdshuff+.005 datameanshuff-datastdshuff],[0 0],'Color','blue',...
                'LineWidth',5)
            line([datameanshuff+datastdshuff datameanshuff+datastdshuff+.005],[0 0],'Color','blue',...
                'LineWidth',5)
            text(t2,datameanshuff,-.075,[num2str(round(datameanshuff,2)) ' ' char(177)...
                ' ' num2str(datastdshuff,'%.e')],'HorizontalAlignment','center','FontSize',8)
            ylim([-0.08 0]) % minimize y-axis height
            xlim([-0.1 2.1])
            t2.YAxis.Visible = 'off'; % hide y-axis
            t2.XAxis.Visible = 'off'; % hide y-axis
            t2.Color = 'None';
            hold off
        end
    end
    
    
    %% "Superviolin" plots of MSD \beta
    ax=nexttile(layout0,3);
    
    rmsf_conds = {{[],[],[],[]},{[],[],[],[]},{[],[],[],[]}};
    
    for ii=1:length(species) % main boxes (species)
        f = find(contains(field_names(:),species(ii)))'; % condition indexes
        for jj = 1:length(f) % secondary boxes (conditions)
            rmsf_conds{ii}{jj} = resultados.(field_names{f(jj)})(:,9);
        end
    end
    
    for ii=1:length(species) % main boxes (species)
        superviolin(rmsf_conds{ii},'Parent',ax,'Xposition',ii,'FaceAlpha',0.15,...
            'Errorbars','ci','Centrals','mean','LineWidth',0.1)
    end
    colorgroups = [ones(length(rmsf_conds{1}{1}),1);
        repmat(2,length(rmsf_conds{1}{2}),1);
        repmat(3,length(rmsf_conds{1}{3}),1);
        repmat(4,length(rmsf_conds{1}{4}),1);
        ones(length(rmsf_conds{2}{1}),1);
        repmat(2,length(rmsf_conds{2}{2}),1);
        repmat(3,length(rmsf_conds{2}{3}),1);
        repmat(4,length(rmsf_conds{2}{4}),1);
        ones(length(rmsf_conds{3}{1}),1);
        repmat(2,length(rmsf_conds{3}{2}),1);
        repmat(3,length(rmsf_conds{3}{3}),1);
        repmat(4,length(rmsf_conds{3}{4}),1)];
    
    rmsfs = {[],[],[]};
    for ii=1:length(species) % species    
        for f = find(contains(field_names(:),species(ii)))' % conditions
            rmsfs{ii} = [rmsfs{ii}; resultados.(field_names{f})(:,9)];
        end
    end
    
    boxChart_rmsf=cat(1,rmsfs{1},rmsfs{2},rmsfs{3});
    boxchart([ones(length(rmsfs{1}),1); repmat(2,length(rmsfs{2}),1); ...
        repmat(3,length(rmsfs{3}),1)],boxChart_rmsf,'Notch','off',...
        'GroupByColor',colorgroups,'BoxFaceAlpha',0)
    h=gca;
    xlim([.5 3.5])
    ylim([1 2.1])
    % h.XAxisLocation = 'top';
    box on
    h.XTick = [1 2 3];
    xticklabels(h,[{'\itAmoeba proteus'},{'\itMetamoeba leningradensis'},...
        {'\itAmoeba borokensis'}])
    h.XAxis.FontSize = 8;
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

