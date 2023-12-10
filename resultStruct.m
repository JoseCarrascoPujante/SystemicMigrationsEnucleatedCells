
function [results,errorList] = resultStruct(tracks)
    
    % dbstop if error
    tCalcSec=tic;
    
    results = struct ;
    errorList = [];
    % List the parameters to be calculated by the script
    stat_names = {'RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2', 'RMSFCorrelationTime', ...
        'DFA_gamma', 'sDFA_gamma', 'MSD_beta', 'sMSD_beta', 'ApEn', 'sApEn', ...
        'Intensity','sIntensity','DR','sDR','AvgSpeed','sAvgSpeed','dispCos'} ;
    
    bar1 = waitbar(0,'','Name','Scenario') ;
    bar1.Children.Title.Interpreter = 'none';
    bar2 = waitbar(0,'','Name','Serie') ;
    bar2.Children.Title.Interpreter = 'none';
    bar3 = waitbar(0,'','Name','Track') ;
    bar3.Children.Title.Interpreter = 'none';    
    
    C = fieldnames(tracks) ;
    for ii = 1:length(C) %for condition...
        
        bar1 = waitbar(ii/length(C), bar1, C{ii}) ;
        
        scenariotime = tic;
           
        S = fieldnames(tracks.(C{ii})); 
        for jj = 1:length(S) % for serie...
            bar2 = waitbar(jj/length(S), bar2, S{jj}) ;
            T = fieldnames(tracks.(C{ii}).(S{jj}).scaled);
            for kk = 1:length(T)
                
                tic
        
                bar3 = waitbar(kk/length(T), bar3, T{kk}) ;
    		        
                % RMSFalpha calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSF_alpha')),...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSF_R2')),...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'RMSFCorrelationTime')), ~,~] = ...
                    enu.rmsf(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk}), [], []) ;
                
                % Shuff RMSFalpha calc
                try
                    [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sRMSF_alpha')),~,~,~,~] = ...
                        enu.rmsf(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk}), [], []) ;
                catch ME
                    disp(ME)
                    errorList = [errorList; string(strcat(C{ii},S{jj},'shuffled_rho',T{kk}))];
                end
                       
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
                
                % Shuff MSDbeta calc
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sMSD_beta'))] = ...
                    enu.msd(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,1), ...
                            tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,2),[]) ;    
    
                % Approximate entropy (Kolmogorov-Sinai entropy)
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'ApEn')) = ...
                    enu.ApEn(2, 0.2*std(tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk})), ...
                             tracks.(C{ii}).(S{jj}).scaled_rho.(T{kk})) ;
        
                % Shuff Approximate entropy (Kolmogorov-Sinai entropy)
                results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sApEn')) = ...
                    enu.ApEn(2, 0.2*std(tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk})), ...
                             tracks.(C{ii}).(S{jj}).shuffled_rho.(T{kk})) ;
        
                % Intensity of response (mm)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'Intensity'))] = ...
                    norm([tracks.(C{ii}).(S{jj}).scaled.(T{kk})(end,1) tracks.(C{ii}).(S{jj}).scaled.(T{kk})(end,2)]...
                    - [tracks.(C{ii}).(S{jj}).scaled.(T{kk})(1,1) tracks.(C{ii}).(S{jj}).scaled.(T{kk})(1,2)]);
        
                % Shuff intensity of response (mm)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sIntensity'))] = ...
                    norm([tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(end,1) tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(end,2)]...
                    - [tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(1,1) tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(1,2)]);
        
                % Directionality ratio (straightness)
                d = hypot(diff(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,1)), diff(tracks.(C{ii}).(S{jj}).scaled.(T{kk})(:,2))) ;
                distTrav = sum(d);
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'DR'))] = ...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'Intensity'))/distTrav;
                
                % Shuff Directionality ratio (straightness)
                d = hypot(diff(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,1)), diff(tracks.(C{ii}).(S{jj}).shuffled.(T{kk})(:,2))) ;
                SdistTrav = sum(d);
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sDR'))] = ...
                    results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'sIntensity'))/SdistTrav;
        
                % Average speed (mm/s)
                [results.(C{ii}).(S{jj})(kk,strcmp(stat_names(:), 'AvgSpeed'))] = ...
                    distTrav/2050;
        
                % Shuff average speed (mm/s)
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
    
    % Save results in .mat file    
    ['Calculations section runtime FINISHED in ' num2str(toc(tCalcSec)) ' seconds']
    
    %save results in .xlsx file
    enu.results2excel(results)
    
    save('numericalResults.mat','tCalcSec', 'results') ;
end