%% Panel A
panelA=figure;
thetaPanelA=[];
B = fieldnames(tracks.x_1noStimuli_Cells);
for BB = 1:length(B)
    C = fieldnames(tracks.x_1noStimuli_Cells.(B{BB}));
    for CC = 1:length(C)
        thetaPanelA = [thetaPanelA tracks.x_1noStimuli_Cells.(B{BB}).(C{CC}).theta(end)];
    end 
end

b = histogram(cos(thetaPanelA),10,"BinEdges",-1:.2:1,'FaceColor','k','LineWidth',2.6);
xticks([-1 0 1])
xlim([-1,1])
yticks([0 max(b.Values)])
ylim([0 max(b.Values)])
ax1 = gca;
ax1.FontSize = 50;
pbaspect([1.2 1 1])
ax1.LineWidth=1.25;

print(panelA,'-vector','-dsvg', ...
    'C:\Users\JoseC\Desktop\El Arca\Académico\Doctorado\Amebas\Papers-sin-nucleo\mov.sist.enucleadas\Fig3PanelA''2.svg')

%% Panel B

panelB=figure;
thetaPanelB=[];
B = fieldnames(tracks.x_1noStimuli_Cytoplasts);
for BB = 1:length(B)
    C = fieldnames(tracks.x_1noStimuli_Cytoplasts.(B{BB}));
    for CC = 1:length(C)
        thetaPanelB = [thetaPanelB tracks.x_1noStimuli_Cytoplasts.(B{BB}).(C{CC}).theta(end)];
    end 
end

b = histogram(cos(thetaPanelB),10,"BinEdges",-1:.2:1,'FaceColor','k','LineWidth',2.6);
xticks([-1 0 1])
xlim([-1,1])
yticks([0 max(b.Values)])
ylim([0 max(b.Values)])
ax2 = gca;
ax2.FontSize = 50;
pbaspect([1.2 1 1])
ax2.LineWidth=1.25;

print(panelB,'-vector','-dsvg', ...
    'C:\Users\JoseC\Desktop\El Arca\Académico\Doctorado\Amebas\Papers-sin-nucleo\mov.sist.enucleadas\Fig3PanelE''2.svg')

