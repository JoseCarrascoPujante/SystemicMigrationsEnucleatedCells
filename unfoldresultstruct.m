function T=unfoldresultstruct(data,colnames)
    a = {};
    colnames = ['Track name' colnames];
    a = enu.unfold(data,'results',false,a);
    b = [];
    p = split(a,'.');

    for ii = 1:length(a)
        disp([a{ii} ' ' '(' num2str(ii) '/' num2str(length(a)) ')'])
        zz = strcat( a{ii}," nº", string(1:size(data.(p{1,ii,2}).(p{1,ii,3}),1))' );
        b = [b; num2cell(zz) num2cell(data.(p{1,ii,2}).(p{1,ii,3}))];
    end
    T=cell2table(b,'VariableNames',colnames);