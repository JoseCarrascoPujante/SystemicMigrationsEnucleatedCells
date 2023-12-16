function results2excel(resultados,stat_names)
    a={};
    a=enu.unfold(resultados,'results',false,a);
    p = split(a,'.');

    for ii = 1:length(a)
        disp([a{ii} ' ' '(' num2str(ii) '/' num2str(length(a)) ')'])
        zz = strcat( a{ii}," nº", string(1:size(resultados.(p{ii,2}).(p{ii,3}),1))' );
        writecell([num2cell(zz) num2cell(resultados.(p{ii,2}).(p{ii,3}))],'resultsTable.xlsx','Sheet',p{ii,2},'WriteMode','append');
    end
    
    excel = actxserver('Excel.Application');
    wb = excel.Workbooks.Open([pwd '\resultsTable.xlsx']);
    sn = sheetnames("resultsTable.xlsx");
    for ss = 1:numel(sn)
        ws = wb.Worksheets.Item(ss);
        ws.Range('A1:S1').Insert;
        ws.Range('A1:S1').Value = ['Cell trajectory ID' stat_names];
    end
    wb.Save;
    excel.Quit;
    delete(excel);
end