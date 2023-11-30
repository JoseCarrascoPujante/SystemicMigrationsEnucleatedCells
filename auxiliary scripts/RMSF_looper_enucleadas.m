clear
close all

load('2023-11-27_22.46''27''''_trajectories.mat')

% Parameter index
stat_names = {'goodness','sgoodness','RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2','sRMSF_R2', ...
    'RMSFCorrelationTime','sRMSFCorrelationTime','goodness','sgoodness'} ;
results = struct;
field_names = fieldnames(coordinates);

diary off
diary_filename = strcat(destination_folder,'\RMSFvalues.txt') ;
set(0,'DiaryFile',diary_filename)
clear diary_filename
diary on

bar1 = waitbar(0,'In progress...','Name','Condition') ;
bar1.Children.Title.Interpreter = 'none';
bar2 = waitbar(0,'In progress...','Name','Track number') ;
bar2.Children.Title.Interpreter = 'none';

tic

for i = 1:length(field_names)
    bar1 = waitbar(i/length(field_names), bar1, field_names{i}) ;
    N = length(coordinates.(field_names{i}).original_x) ; % N trajectories in condition
    for j = 1:N
        bar2 = waitbar(j/N, bar2, strcat('Track number', ' ', num2str(j))) ;
        [results.(field_names{i})(j,strcmp(stat_names(:), 'RMSF_alpha')),...
            results.(field_names{i})(j,strcmp(stat_names(:), 'RMSF_R2')),...
            results.(field_names{i})(j,strcmp(stat_names(:), 'RMSFCorrelationTime')),...
            results.(field_names{i})(j,strcmp(stat_names(:), 'goodness'))] =...
            RMSFgoodnessdisp(coordinates.(field_names{i}).scaled_rho{j}) ;
        
        
        [results.(field_names{i})(j,strcmp(stat_names(:), 'sRMSF_alpha')),...
            results.(field_names{i})(j,strcmp(stat_names(:), 'sRMSF_R2')),...
            results.(field_names{i})(j,strcmp(stat_names(:), 'sRMSFCorrelationTime')),...
            results.(field_names{i})(j,strcmp(stat_names(:), 'sgoodness'))] =...
            RMSFgoodnessdisp(coordinates.(field_names{i}).shuffled_rho{j});

        % Print RMSF values
        [field_names{i} 'nº' num2str(j) ':' ...
            newline 'goodness:' ' ' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'goodness')))...
            newline 'alpha:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'RMSF_alpha')))...
            newline 'R2:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'RMSF_R2')))...
            newline 'MaxCorrTime:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'RMSFCorrelationTime')))...
            newline 'sgoodness:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'sgoodness')))...
            newline 'Shuff alpha:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'sRMSF_alpha'))) ...
            newline 'Shuff R2:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'sRMSF_R2'))) ...
            newline 'Shuff MaxCorrTime:' num2str(results.(field_names{i})(j,strcmp(stat_names(:), 'sRMSFCorrelationTime')))]
    end
end

toc

diary off

