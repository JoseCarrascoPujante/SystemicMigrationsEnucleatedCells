function ks=k_s(resultados)
    field_names=fieldnames(resultados);
    for field = 1:length(field_names)
        a={};a=enu.unfold(resultados.(field_names{field}),strcat('resultados.',field_names{field}),false,a);
        p = split(a,'.');
        b=[];
        for ii = 1:length(a)
            b = [b; resultados.(p{ii,2}).(p{ii,3})];
        end        
        n_hypotheses = size(b,1) ; % N hypotheses (cells) being tested, for Bonferroni correction)
        
        for column_index = 2:size(b,2)
    
            x = (b(:,column_index) - mean(b(:,column_index))) / std(b(:,column_index)) ;
            
            [hypothesis, p_value, ksstat, cv] = kstest(x,'Alpha',(0.05/n_hypotheses)) ; % with Bonferroni correction
    
            ks.(field_names{field})(2,column_index) = p_value ;
            ks.(field_names{field})(1,column_index) = hypothesis ;        
            ks.(field_names{field})(3,column_index) = ksstat ;
            ks.(field_names{field})(4,column_index) = cv ;
            
        end
    end
end