%% Panel A Survival curve and bars
brr=0:34;
for ii=1:35
    deathrate(ii)=sum(CytoplastsLifespanArray>=brr(ii));
end

b = bar(0:34,deathrate,'FaceAlpha',.5);
title('Enucleated cell survival curve')

hold on
plot(0:34,deathrate,'LineWidth',2)

% number for each bar
s = compose('%d', deathrate);
yOffset = 10; % tweak, as necessary
text(b.XData, b.YEndPoints + yOffset, s, "FontSize", 9,'HorizontalAlignment','center');
% fill([0:34 fliplr(0:34)], [deathrate zeros(size(deathrate))], 'blue', 'FaceAlpha', 0.25);
ylim([0 350])
xlim([-1 35])
hold off

%% Panel B Survival histogram
h = histogram(CytoplastsLifespanArray(CytoplastsLifespanArray<34.1666),0:34,'FaceAlpha',.5);
edges = h.BinEdges;
values = string(round(h.Values*100/length(CytoplastsLifespanArray),1));
% The center of each bin is its left edge plus half the distance to the right edge (which is where diff comes in.)
centers = edges(1:end-1)+diff(edges)/2;
% Now let's put the text 10% above the top of each bin. You may want to tweak the actual y values, since the labels for the shortest bins will overlap the bins themselves.
text(centers, h.Values+0.55, strcat(values, '%'), 'HorizontalAlignment', 'center','FontSize', 8.5)
% Adjust the limits of the axes to fit the highest bar's label.
ylim(ylim.*[1 2.5])

title('Enucleated cell death frequency histogram','FontSize',16)
