function T = RMSFgoodnessCalc(tracks)
a={};
a=unfold(tracks,'tracks',false,a);
a=a(contains(a,'scaled_rho'));

mycell = cell(numel(a),5);
tic
for v = 1:length(a)
    temp = eval(a{v});
    temp2 = eval(strrep(a{v},'scaled_rho','original'));
    mycell(v,:) = {a{v} goodness(temp) length(temp) temp2(1,1) temp2(1,2)};
    disp([a{v} ' ' '(' num2str(v) '/' num2str(length(a)) ')'])
end
toc
T = cell2table( mycell, 'VariableNames',{'Experiment' 'Goodness' 'Length' 'Initial X' 'Initial Y'} );



