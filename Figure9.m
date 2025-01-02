%% Figure 9
function Figure9(T,destination_folder)
    fig = figure('Visible','off','Position', [0 0 1500 911]);
    
    % non-kynetic metrics
    tableColNames = {'RMSF\alpha' 'sRMSF\alpha' 'DFA\gamma' 'sDFA\gamma' ...
        'MSD\beta' 'sMSD\beta' 'Approximate Entropy' 'sApproximate Entropy'} ;
    conf = 68.27;             % set to either a confidence or STD value. 68.27% CI equals 1xSTD
    
    % pair stats
    combinaciones = nchoosek(tableColNames(~startsWith(tableColNames,'s')),2);    
    [~, pairs] = ismember(combinaciones, tableColNames); % metric index for comparison on each panel
    
    % build axes positions
    props = {'sh', 0.02, 'sv', 0.03, 'padding', 0.02 'margin', 0.01};
    hBig = [enu.subaxis(2,3,1, props{:}) enu.subaxis(2,3,2, props{:})...
        enu.subaxis(2,3,3, props{:}) enu.subaxis(2,3,4, props{:}) ...
        enu.subaxis(2,3,5, props{:}) enu.subaxis(2,3,6, props{:})]; % create subplots
    posBig = get(hBig, 'Position');                         % record their positions
    delete(hBig)                                            % delete them
    
    % Create axes (big/small)
    hAxB(1) = axes('Position',posBig{1});
    hAxB(2) = axes('Position',posBig{2});
    hAxB(3) = axes('Position',posBig{3});
    hAxB(4) = axes('Position',posBig{4});
    hAxB(5) = axes('Position',posBig{5});
    hAxB(6) = axes('Position',posBig{6});
    
    parT = table2array(T(:,[4,5,8:13])); % Store metrics being compared in a separate array
    g = contains(T.("Track name"),'Cells');
    % Plot big axes
    for ej=1:size(pairs,1)
        disp(strcat('Plot nº',num2str(ej),': ',tableColNames{pairs(ej,1)},'_vs_',tableColNames{pairs(ej,2)}))
        metric1 = parT(:,pairs(ej,1));
        metric2 = parT(:,pairs(ej,2));
        
        gscatter(hAxB(ej),metric1, metric2, g,[0 0 .5; .9 .1 .64],'..',25 ,'off', ...
            tableColNames{pairs(ej,1)},tableColNames{pairs(ej,2)});

        hold(hAxB(ej),'on')
        enu.ellipse_scatter(hAxB(ej),cat(2,metric1,metric2),conf,'r')
    end
    
   
    %# set axes properties
    set(hAxB, 'Color','w', 'XColor','k', 'YColor','k','FontSize',14,'FontWeight','normal')
       
    %% Export as vector graphics svg file

    versions = dir(destination_folder) ;
    gabs = 0 ;
    for v = 1:length(versions)
        if contains(versions(v).name, 'Fig9'+wildcardPattern+'.svg')
            gabs = gabs + 1 ;
        end
    end
    
    disp(strcat(num2str(gabs),' Fig9 files found'))
    set(fig, 'InvertHardcopy', 'off')
    set(fig, 'Color', 'none');
    % saveas(fig, [destination_folder '\Fig9(',num2str(gabs+1),')' '.svg'])
    print(fig,'-vector','-dsvg',[destination_folder '\Fig9(',num2str(gabs+1),')' '.svg'])
end