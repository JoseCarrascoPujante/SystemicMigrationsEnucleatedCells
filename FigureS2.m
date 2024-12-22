f = figure('Visible','off','Position',[0 0 1000 780]);
brr = 0:35;
CytoplastsLifespanArray = TrackLength./120;

for ii=1:35
    deathrate(ii)=sum(CytoplastsLifespanArray>=brr(ii));
end
plot(0:34,deathrate)
fill([0:34 fliplr(0:34)], [deathrate zeros(size(deathrate))], 'blue', 'FaceAlpha', 0.25);

% Survival histogram
hold on
h = histogram(CytoplastsLifespanArray, 0:35,'FaceColor','#D95319','FaceAlpha',1);
edges = h.BinEdges;
values = string(round(h.Values*100/length(CytoplastsLifespanArray),1));
% The center of each bin is its left edge plus half the distance to the right edge (which is where diff comes in.)
centers = edges(1:end-1)+diff(edges)/2;
% Now let's put the text 10% above the top of each bin. You may want to tweak the actual y values, since the labels for the shortest bins will overlap the bins themselves.
text(centers(1:15), h.Values(1:15)+8, strcat(values(1:15), '%'), 'HorizontalAlignment', ...
    'center','FontWeight','bold')
% Adjust the limits of the axes to fit the highest bar's label.
xlim([0 15])
ylim([0 296])
xlabel("Time after enucleation (minutes)")
ylabel("Enucleated cell death rate (N per minute)")
xticks(1:35)
xticklabels(string(1:35))

title('Curve of enucleated cell survival', 'FontSize', 16)
fontsize(scale=1.5)
box off

print(f,'-vector','-dsvg','C:\Users\JoseC\Desktop\FigS2.svg')
print(f,'-image','-djpeg','-r330','C:\Users\JoseC\Desktop\FigS2.jpg')