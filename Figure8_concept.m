%% Figure 8

function Figure8_concept(T,destination_folder)
    
    fig = figure('Visible','off','Position', [0 0 1215 1215]);
    layout0 = tiledlayout(3,3,'TileSpacing','loose','Padding','none') ;
    
    % Intensity of response (mm)
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'Intensity',T)

    % Directionality ratio (straightness)
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'DR',T)
    
    % Average speed (mm/s)
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'AvgSpeed',T)
  
    % RMSF a
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'RMSF_alpha',T)
    
    % RMSF correlation time
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'RMSFCorrelationTime',T)
    
    % MSD beta
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'MSD_beta',T)

    % ApEn beta
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'ApEn',T)

    % DFA Gamma
    ax = nexttile(layout0);
    kyneticBoxplots(ax,'DFA_gamma',T)



    %% Export as jpg and vector graphics svg file
    
    if ~exist(strcat(destination_folder,'\Figures'), 'dir')
       mkdir(strcat(destination_folder,'\Figures'))
    end
    
    versions = dir(strcat(destination_folder,'\Figures\')) ;
    gabs = 1 ;
    for v = 1:length(versions)
        if  contains(versions(v).name, 'Figure8_concept'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs-1),' Fig8 files found'))
    print(fig,'-vector','-dsvg',[destination_folder '\Figures\Figure8_concept(',num2str(gabs),')' '.svg'])
    print(fig,'-image','-djpeg','-r400',[destination_folder '\Figures\Figure8_concept(',num2str(gabs),')' '.jpg'])        
    
    %% Panel function
    function kyneticBoxplots(ax,string,T)
    % Grouped boxplot chart
        scenarios = {
        'x_1noStimuli_Cells'
        'x_2galvanotaxis_Cells'
        'x_3chemotaxis_Cells'
        'x_4doubleStimulus_Cells'
        'x_1noStimuli_Cytoplasts'
        'x_2galvanotaxis_Cytoplasts'
        'x_3chemotaxis_Cytoplasts'
        'x_4doubleStimulus_Cytoplasts'
        };
        
        boxvalues = [];
        for ii = 1:length(scenarios)
            boxvalues = [boxvalues; T(contains(T.(1),scenarios{ii}),string)];
        end        
        boxvalues = table2array(boxvalues);
        boxgroups{1} = [repmat({'Cells'},200,1); repmat({'Cytoplasts'},200,1)];
        
        boxgroups{2} = [
            repmat({'Sc1'},50,1);
            repmat({'Sc2'},50,1);
            repmat({'Sc3'},50,1);
            repmat({'Sc4'},50,1);
            repmat({'Sc1'},50,1);
            repmat({'Sc2'},50,1);
            repmat({'Sc3'},50,1);
            repmat({'Sc4'},50,1)
            ];
        
        % Box plot
        b = boxplot(boxvalues,boxgroups,'Notch','off','LabelVerbosity','majorminor',...
            'FactorGap',[10,2],'colors',...
            [.9 0 .9;.9 0 .9;.9 0 .9;.9 0 .9;0 .6 .6;0 .6 .6;0 .6 .6;0 .6 .6],'Symbol','');
        hold(ax,"on")
        set(findobj(ax,'Type','text'),'FontSize',10);
        set(b(5:7:end),'LineWidth',.8);
        set(b(6:7:end),'LineWidth',.8);
        % h=findobj('LineStyle','--'); set(h, 'LineStyle','-'); % Make whiskers a solid line
        
        scatcolours = [
            repmat([.9 0 .9],50,1);
            repmat([.9 0 .9],50,1);
            repmat([.9 0 .9],50,1);
            repmat([.9 0 .9],50,1);
            repmat([0 .6 .6],50,1);
            repmat([0 .6 .6],50,1);
            repmat([0 .6 .6],50,1);
            repmat([0 .6 .6],50,1)
            ];
        
        meanValPosition = [ % ~1.15 default separation between box plots
            repmat(1.5,50,1);
            repmat(2.65,50,1);
            repmat(3.8,50,1);
            repmat(4.95,50,1);
            repmat(6.6,50,1);
            repmat(7.75,50,1);
            repmat(8.9,50,1);
            repmat(10.05,50,1)
            ];

        scatter(meanValPosition',boxvalues,5,scatcolours,'jitter','off','jitterAmount',0, ...
            'LineWidth',.3);
        
        % Plot mean values
        meanVal = groupsummary(boxvalues,meanValPosition,'mean');
        plot(unique(meanValPosition)-.5,meanVal,'ob','LineWidth',.8,'MarkerSize',6)
        xlim(ax,[.5 10.5])
        box off
        ylabel(string,"FontSize",10)
    end
end