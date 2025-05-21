% Panel A Survival curve and bars
f = figure('Visible','off','Position',[0 0 1000 780]);
yyaxis left
brr=0:34;
CytoplastsLifespanArray = TrackLength./120;
for ii=1:35
    deathrate(ii)=sum(CytoplastsLifespanArray>=brr(ii));
end
plot(0:34,deathrate)
fill([0:34 fliplr(0:34)], [deathrate zeros(size(deathrate))], 'blue', 'FaceAlpha', 0.25);
ylim([0 300])
xlim([0 15])
xlabel("Time (minutes)")
ylabel("Number of surviving cytoplasts")

% Survival histogram
hold on
yyaxis right
h = histogram(CytoplastsLifespanArray(CytoplastsLifespanArray<34.1666),0:34,'FaceAlpha',1);
edges = h.BinEdges;
xticks([0:34])
values = string(round(h.Values*100/length(CytoplastsLifespanArray),1));
% The center of each bin is its left edge plus half the distance to the right edge (which is where diff comes in.)
centers = edges(1:end-1)+diff(edges)/2;
% Now let's place the text 10% above the top of each bin. You may want to tweak the actual y values, since the labels for the shortest bins will overlap the bins themselves.
text(centers, h.Values+1.75, strcat(values, '%'), 'HorizontalAlignment', ...
    'center','FontSize', 8,'FontWeight','bold')
% Adjust the limits of the axes to fit the highest bar's label.
ylim(ylim.*[1 15])
ylabel("Cytoplast death rate (N)")
fontsize(gcf,scale=1.5)
title('Enucleated cell survival curve and death rate histogram','FontSize',16)

print(f,'-vector','-dsvg','C:\Users\JoseC\Desktop\FigS2.svg')
print(f,'-image','-djpeg','-r330','C:\Users\JoseC\Desktop\FigS2.jpg')