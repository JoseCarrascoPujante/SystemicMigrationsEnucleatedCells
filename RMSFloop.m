
function [Tcells,Tcytops] = RMSFloop(tracks)
    a={};
    a=enu.unfold(tracks,'tracks',false,a);
    a=a(contains(a,'scaled_rho'));
    p = split(a,'.');
    
    varTypes = ["string","double","double","double","double","double","double"];
    Tcells = table('Size',[sum(contains(a,'_Cells')) 7],'VariableTypes',varTypes,'VariableNames', ...
        {'Cell experiments' 'alpha Cells' 'r2 Cells' 'Max Memory Cells' 'Length Cells' 'Initial X Cells' 'Initial Y Cells'});
    Tcytops = table('Size',[sum(contains(a,'_Cytoplasts')) 7],'VariableTypes',varTypes,'VariableNames', ...
        {'Cytoplast experiments' 'alpha Cytoplasts' 'r2 Cytoplasts' 'MaxMemory Cytoplasts' 'Length Cytoplasts' 'Initial X Cytoplasts' 'Initial Y Cytoplasts'});
    
    ixcells = 0;
    ixcytops = 0;
    tic
    for v = 1:length(a)

        disp([a{v} ' ' '(' num2str(v) '/' num2str(length(a)) ')'])
        temp = tracks.(p{1,v,2}).(p{1,v,3}).scaled_rho.(p{1,v,5});
        temp2 = tracks.(p{1,v,2}).(p{1,v,3}).original.(p{1,v,5});
        [alpha,r2,memory,~,~] = enu.rmsf(temp,[],[]);
        if contains(a{v},'_Cells')
            ixcells = ixcells + 1;
            Tcells(ixcells,:) = { a{v} alpha r2 memory length(temp) temp2(1,1) temp2(1,2) };
        elseif contains(a{v},'_Cytoplasts')
            ixcytops = ixcytops + 1;
            Tcytops(ixcytops,:) = { a{v} alpha r2 memory length(temp) temp2(1,1) temp2(1,2) };
        end

    end
    toc

    writetable(Tcells,'rmsfTable.xlsx','Sheet','Cells');
    writetable(Tcytops,'rmsfTable.xlsx','Sheet','Cytoplasts');    
end