function [Tcells,Tcytops,figures] = DFAloop(tracks)
    a={};
    a=enu.unfold(tracks,'tracks',false,a);
    a=a(contains(a,'scaled_rho'));
    p = split(a,'.');
    
    figures = cell(length(a),3);
    varTypes = ["string","double","double","double","double","double"];
    Tcells = table('Size',[sum(contains(a,'_Cells')) 6],'VariableTypes',varTypes,'VariableNames', ...
        {'Cell experiments' 'DFA gamma cells' 'sDFA gamma cells' 'Length Cells' 'Initial X Cells' 'Initial Y Cells'});
    Tcytops = table('Size',[sum(contains(a,'_Cytoplasts')) 6],'VariableTypes',varTypes,'VariableNames', ...
        {'Cytoplast experiments' 'DFA gamma Cytoplasts' 'sDFA gamma Cytoplasts' 'Length Cytoplasts' 'Initial X Cytoplasts' 'Initial Y Cytoplasts'});
    
    ixcells = 0;
    ixcytops = 0;
    tic
    for v = 1:length(a)
        disp([a{v} ' ' '(' num2str(v) '/' num2str(length(a)) ')'])
        
        figures{v,1} = a{v} ;
        figures{v,2} = figure('Name',a{v},'NumberTitle','off','Visible','off') ;
        h = gca;
        
        temp = tracks.(p{1,v,2}).(p{1,v,3}).scaled_rho.(p{1,v,5});
        
        gamma = enu.DFA_main2(temp,'original',h);
        figures{v,3}=figure('Name',strcat("shuffled ", a{v}),'NumberTitle','off','Visible','off') ;
        h = gca;
        stemp = tracks.(p{1,v,2}).(p{1,v,3}).shuffled_rho.(p{1,v,5});
        sgamma = enu.DFA_main2(stemp,'shuffled',h);
        temp2 = tracks.(p{1,v,2}).(p{1,v,3}).original.(p{1,v,5});
        if contains(a{v},'_Cells')
            ixcells = ixcells + 1;
            Tcells(ixcells,:) = { a{v} gamma sgamma length(temp) temp2(1,1) temp2(1,2) };
        elseif contains(a{v},'_Cytoplasts')
            ixcytops = ixcytops + 1;
            Tcytops(ixcytops,:) = { a{v} gamma sgamma length(temp) temp2(1,1) temp2(1,2) };
        end

    end
    toc

    writetable(Tcells,'DFAtable.xlsx','Sheet','Cells');
    writetable(Tcytops,'DFAtable.xlsx','Sheet','Cytoplasts');    
end
