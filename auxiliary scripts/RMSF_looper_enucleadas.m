clear
close all

load('2023-12-01_16.55''38''''_trajectories.mat')

% Parameter index
stat_names = {'goodness','sgoodness','RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2','sRMSF_R2', ...
    'RMSFCorrelationTime','sRMSFCorrelationTime','goodness','sgoodness'} ;
results = struct;
scenarios = fieldnames(tracks);
e = dictionary;
tic

for i = 1:length(scenarios)
    l = fieldnames(tracks.(scenarios{i}));
    for j = 1:length(l)
        m = fieldnames(tracks.(scenarios{i}).(l{j}).scaled_rho);
        for k = 1:length(m)
            results.(scenarios{i}).(l{j}).(m{k})(1) =...
                RMSFgoodness(tracks.(scenarios{i}).(l{j}).scaled_rho.(m{k})) ;
            
            
            % Print RMSF values
            e([scenarios{i} l{j} 'nº' num2str(k)]) = ...
                results.(scenarios{i}).(l{j}).(m{k})(1)
        end
    end
end

f = sortrows(entries(e),2,'descend');

toc
