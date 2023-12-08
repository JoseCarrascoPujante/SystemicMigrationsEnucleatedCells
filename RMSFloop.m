function T = RMSFloop(tracks)
    a={};
    a=enu.unfold(tracks,'tracks',false,a);
    a=a(contains(a,'scaled_rho'));
    
    mycell = cell(numel(a),7);
    tic
    for v = 1:length(a)
        disp([a{v} ' ' '(' num2str(v) '/' num2str(length(a)) ')'])
        temp = eval(a{v});
        temp2 = eval(strrep(a{v},'scaled_rho','original'));
        [alpha,r2,memory,~,~] = enu.rmsf(temp,[],[])
        mycell(v,:) = {a{v} alpha r2 memory length(temp) temp2(1,1) temp2(1,2)};
        
    end
    toc
    T = cell2table( mycell, 'VariableNames',{'Experiment' 'alpha' 'r2' 'MaxMemory' 'Length' 'Initial X' 'Initial Y'} );
end