
function T=resultStruct2table(resultados,stat_names)
    a = {};
    stat_names = ['Track name' stat_names];
    a = enu.unfold(resultados,'results',false,a);
    b = [];
    p = split(a,'.');

    for ii = 1:length(a)
        disp([a{ii} ' ' '(' num2str(ii) '/' num2str(length(a)) ')'])
        zz = strcat( a{ii}," nº", string(1:size(resultados.(p{ii,2}).(p{ii,3}),1))' );
        b = [b; num2cell(zz) num2cell(resultados.(p{ii,2}).(p{ii,3}))];
    end
    T=cell2table(b,'VariableNames',stat_names);