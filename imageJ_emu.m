function imageJ_emu(coordinates)
frameDir = 'E:\Doctorado\Amebas\Papers enucleadas TODO\frames enucleadas completos\';
fig = figure('Position', [0 0 1200 770]);
f_n = fieldnames(coordinates);
button = '';
Previous = uicontrol('String','Previous','Position',[30 10 90 30]);
Next = uicontrol('String','Next','Position',[130 10 90 30]);
slider = uicontrol('Style','slider','Position',[80 605 900 20]);
f = 1;
i = 1;
while f <= length(f_n)
    while i <= size(coordinates.(f_n{f}).scaled_x,2)
        Previous.Callback = {@ButtonMode,fig};
        Next.Callback = {@ButtonMode,fig};
        plot(coordinates.(f_n{f}).scaled_x{i}, ...
            coordinates.(f_n{f}).scaled_y{i},'Color','b')
        hold on
        plot(coordinates.(f_n{f}).scaled_x{i}(end), ...
            coordinates.(f_n{f}).scaled_y{i}(end),...
            'ko','MarkerFaceColor','r','MarkerSize', 2)
        text(.05,.95,[f_n{f},'_nº',num2str(i)],'Units','normalized','Interpreter','none')
        axis equal
%%% Uncomment the following lines to "square up" the plots
        % if MaxX > MaxY 
        %     axis([-MaxX MaxX -MaxY*(MaxX/MaxY) MaxY*(MaxX/MaxY)]);
        % elseif MaxY > MaxX
        %     axis([-MaxX*(MaxY/MaxX) MaxX*(MaxY/MaxX) -MaxY MaxY]);
        % elseif MaxY == MaxX
        %     axis([-MaxX MaxX -MaxY MaxY]);
        % end

        % Head to video frames dir
        scenarioAndCondition = strsplit(f_n{f}, '_');
        cd(string(strcat(frameDir,scenarioAndCondition(1),'\',scenarioAndCondition(2),'\')))
        listofstrings = extractfield(dir('*mkv'),'name');
        v = VideoReader(strnearest(,listofstrings));

        t = uicontrol('String',[currentframe '/' allframes],'frame','Style','text','Enable','inactive');
        hold off
        uiwait(fig)
        if contains(button,'Next')
            i = i + 1;
        elseif contains(button,'Previous')
            if (i ~= 1)
                i = i - 1;
            elseif (i == 1) && (f == 1)
                msgbox('First entry of the dataset has been reached')
            elseif (i == 1) && (f ~= 1)
                f = f - 1;
                i = size(coordinates.(f_n{f}).scaled_x,2) ;
            end
        end
    end
    f = f + 1;
    i = 1;
end
function ButtonMode(object,~,fig)
if strcmpi(object.String, 'Previous')
    button = 'Previous';
    uiresume(fig)
elseif strcmpi(object.String, 'Next')
    button = 'Next';
    uiresume(fig)
end
end
end