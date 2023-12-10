
function results = resultStruct(tracks)
    
    dbstop if error
    tCalcSec=tic;
    
    results = struct ;
    % List the parameters to be calculated by the script
    stat_names = {'RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2', 'RMSFCorrelationTime', ...
        'DFA_gamma', 'sDFA_gamma', 'MSD_beta', 'sMSD_beta', 'ApEn', 'sApEn', ...
        'Intensity','sIntensity','DR','sDR','AvgSpeed','sAvgSpeed','dispCos'} ;
    
    bar3 = waitbar(0,'In progress...','Name','Scenario') ;
    bar3.Children.Title.Interpreter = 'none';
    bar4 = waitbar(0,'In progress...','Name','Track') ;
    bar4.Children.Title.Interpreter = 'none';
    
    C = fieldnames(tracks) ;
    for ii = 1:length(C) %for condition...
        
        bar3 = waitbar(ii/length(C), bar3, C{ii}) ;
        
        scenariotime = tic;
           
        S = fieldnames(tracks.(C{ii})); 
        for jj = 1:length(S) % for serie...
            T = fieldnames(tracks.(C{ii}).(S{jj}).scaled);
            for kk = 1:length(T)
                
                tic
        
                bar4 = waitbar(kk/length(T), bar4, strcat(S{jj},'nº',T{kk})) ;
    		        
                % RMSFalpha calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSF_alpha')),...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSF_R2')),...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSFCorrelationTime')), ~,~] = ...
                    enu.rmsf(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk}), [], []) ;
                
                % Shuffl RMSFalpha calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sRMSF_alpha')),~,~,~,~] = ...
                    enu.rmsf(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk}), [], []) ;
                       
                % DFAgamma calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'DFA_gamma'))] = ...
                    enu.DFA_main2(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk}),[], []) ;
        
                % Shuff DFAgamma calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sDFA_gamma'))] = ...
                    enu.DFA_main2(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk}),[], []) ;
            
                % MSDbeta calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'MSD_beta'))] = ...
                    enu.msd(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,1), ...
                            tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,2),[]) ;
                
                % Shuffled MSDbeta calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sMSD_beta'))] = ...
                    enu.msd(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,1), ...
                            tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,2),[]) ;    
    
                % Approximate entropy (Kolmogorov-Sinai entropy)
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'ApEn')) = ...
                    enu.ApEn(2, 0.2*std(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk})), ...
                             tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk})) ;
        
                % Shuffled Approximate entropy (Kolmogorov-Sinai entropy)
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sApEn')) = ...
                    enu.ApEn(2, 0.2*std(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk})), ...
                             tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk})) ;
        
                % Intensity of response (mm)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'Intensity'))] = ...
                    norm([tracks.(C{ii}).(S{jj}).scaled.(T{kk})(end,1) tracks.(C{ii}).(S{jj}).scaled.(T{kk})(end,2)]...
                    - [tracks.(C{ii}).(S{jj}).scaled.(T{kk})(1,1) tracks.(C{ii}).(S{jj}).scaled.(T{kk})(1,2)]);
        
                % Shuffled intensity of response (mm)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sIntensity'))] = ...
                    norm([tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(end,1) tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(end,2)]...
                    - [tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(1,1) tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(1,2)]);
        
                % Directionality ratio (straightness)
                d = hypot(diff(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,1)), diff(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,2))) ;
                distTrav = sum(d);
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'DR'))] = ...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'Intensity'))/distTrav;
                
                % Shuffled Directionality ratio (straightness)
                d = hypot(diff(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,1)), diff(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,2))) ;
                SdistTrav = sum(d);
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sDR'))] = ...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sIntensity'))/SdistTrav;
        
                % Average speed (mm/s)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'AvgSpeed'))] = ...
                    distTrav/2050;
        
                % Shuffled average speed (mm/s)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sAvgSpeed'))] = ...
                    SdistTrav/2050;
    
                %Displacement cosines
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'dispCos'))] = ...
                    cos(tracks.(C{ii}).(S{jj}).theta.(T{kk})(end));
        
                [C{ii} ' ' S{jj} 'nº' num2str(kk) ' runtime was ' num2str(toc) ' seconds']
            end
        end
    
        [C{ii} ' runtime was ' num2str(toc(scenariotime)) ' seconds']
    
    end
    
    %# Save data
    
    ['Calculations section runtime FINISHED in ' num2str(toc(tCalcSec)) ' seconds']
    
    save(numericalResults.mat','tCalcSec', 'results') ;
end