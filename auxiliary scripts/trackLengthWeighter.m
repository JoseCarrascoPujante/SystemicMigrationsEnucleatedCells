function trackLengthViewer(coordinates)
    a={};
    a=unfold(coordinates,'coordinates',false,a);
    a=a(contains(a,'original_x'));
    a = extractBetween(a,'.','.');
    
    trackLengths = dictionary;
    for i = 1:length(a)
        for j = 1:length(coordinates.(a{i}).original_x)
            trackLengths([a{i} ' ' num2str(j)]) = length(coordinates.(a{i}).original_x{j});
        end
    end
    
    e = sortrows(entries(trackLengths),2,'descend');
    
    figure
    idx1 = find(e{:,2} >= 1800);
    idx2 = find(e{:,2} < 1800);
    fill([1,1:idx1(end),idx1(end)+1],[min(e{:,2}); e{:,2}(idx1); min(e{:,2})],[1:-.3/idx1(end):0.7,0.7], ...
        [idx2(1),idx2(1):idx2(end)],[min(e{:,2}); e{:,2}(idx2)],[-.3:.3/(idx2(end)-idx2(1)):0,0], ...
        [1,1:idx2(end),idx2(end)+1],[1; repmat(min(e{:,2}),length(e{:,2}),1);1],[.45:-.2/length(e{:,2}):0.25,0.25])
    colormap("turbo")
    
    text(median(idx1), mean(e{:,2}), ...
        strcat(num2str(((sum(e{:,2}(idx1))-(min(e{:,2})*length(e{:,2}(idx1))))/sum(e{:,2}))*100),'%'), ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom','Color','w')
    
    text(median(idx2), mean(e{:,2}(idx2)), ...
        strcat(num2str(((sum(e{:,2}(idx2))-(min(e{:,2})*length(e{:,2}(idx2))))/sum(e{:,2}))*100),'%'), ...
        'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom','Color','k')
    
    text(length(e{:,2})/2, min(e{:,2})/2, ...
        strcat(num2str((min(e{:,2})*length(e{:,2})/sum(e{:,2}))*100),'%'),'HorizontalAlignment', 'right', ...
         'VerticalAlignment', 'bottom')
    
    text(max(idx1), min(e{:,2}(idx1))+100, strcat('y=',num2str(1800),'\newlinex=', ...
        num2str(length(idx1)),'\newline\downarrow'),'HorizontalAlignment', ...
        'left', 'VerticalAlignment', 'bottom','FontSize',11)
    
    text(max(idx2), min(e{:,2}), strcat('\leftarrow','y=',num2str(min(e{:,2})), ...
        '\newline    x=',num2str(length(e{:,2}))), 'HorizontalAlignment', ...
        'left','VerticalAlignment', 'cap','FontSize',11)
    
    xlabel('Trayectorias en orden de longitud descendente')
    ylabel('Número de puntos')
end