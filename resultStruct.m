
function [resultados,T442,errorList] = resultStruct(tracks)
    
    % dbstop if error
    tCalcSec=tic;
    
    resultados = struct ;
    errorList = [];
    % List the parameters to be calculated by the script
    stat_names = {'Side','Track length','RMSF_alpha', 'sRMSF_alpha', 'RMSF_R2', 'RMSFCorrelationTime', ...
        'DFA_gamma', 'sDFA_gamma', 'MSD_beta', 'sMSD_beta', 'ApEn', 'sApEn', ...
        'Intensity','sIntensity','DR','sDR','AvgSpeed','sAvgSpeed','dispCos'} ;
    
    bar1 = waitbar(0,'','Name','Scenario') ;
    bar1.Children.Title.Interpreter = 'none';
    bar2 = waitbar(0,'','Name','Serie') ;
    bar2.Children.Title.Interpreter = 'none';
    bar3 = waitbar(0,'','Name','Track') ;
    bar3.Children.Title.Interpreter = 'none';    
    
    A = fieldnames(tracks) ;
    for aa = 1:length(A) %for condition...
        
        bar1 = waitbar(aa/length(A), bar1, A{aa}) ;
        
        scenariotime = tic;
           
        B = fieldnames(tracks.(A{aa})); 
        for bb = 1:length(B) % for serie...
            bar2 = waitbar(bb/length(B), bar2, B{bb}) ;
            C = fieldnames(tracks.(A{aa}).(B{bb}));
            for cc = 1:length(C)
                
                tic
        
                bar3 = waitbar(cc/length(C), bar3, C{cc}) ;

                %Left (0) or right (1) net displacement
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'Side')) = ...
                    double(tracks.(A{aa}).(B{bb}).(C{cc}).original(end,1)...
                    > tracks.(A{aa}).(B{bb}).(C{cc}).original(1,1));                
    		    
                %Track length
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'Track length')) = ...
                    length(tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho);
                
                % RMSF calc
                [resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'RMSF_alpha')),...
                    resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'RMSF_R2')),...
                    resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'RMSFCorrelationTime')), ~,~] = ...
                    enu.rmsf(tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho, []) ;
                
                % Shuff RMSF calc
                try
                    [resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sRMSF_alpha')),~,~,~,~] = ...
                        enu.rmsf(tracks.(A{aa}).(B{bb}).(C{cc}).shuffled_rho, []) ;
                catch ME
                    disp(ME)
                    errorList = [errorList; string(strcat(A{aa},B{bb},'shuffled_rho',C{cc}))];
                end
                       
                % DFAgamma calc
                [resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'DFA_gamma'))] = ...
                    enu.DFA_main2(tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho,[], []) ;
        
                % Shuff DFAgamma calc
                [resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sDFA_gamma'))] = ...
                    enu.DFA_main2(tracks.(A{aa}).(B{bb}).(C{cc}).shuffled_rho,[], []) ;
            
                % MSDbeta calc
                [resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'MSD_beta'))] = ...
                    enu.msd(tracks.(A{aa}).(B{bb}).(C{cc}).scaled(:,1), ...
                            tracks.(A{aa}).(B{bb}).(C{cc}).scaled(:,2),[]) ;
                
                % Shuff MSDbeta calc
                [resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sMSD_beta'))] = ...
                    enu.msd(tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(:,1), ...
                            tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(:,2),[]) ;    
    
                % Approximate entropy (Kolmogorov-Sinai entropy)
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'ApEn')) = ...
                    enu.ApEn(2, 0.2*std(tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho), ...
                             tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho) ;
        
                % Shuff Approximate entropy (Kolmogorov-Sinai entropy)
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sApEn')) = ...
                    enu.ApEn(2, 0.2*std(tracks.(A{aa}).(B{bb}).(C{cc}).shuffled_rho), ...
                             tracks.(A{aa}).(B{bb}).(C{cc}).shuffled_rho) ;
        
                % Intensity of response (mm)
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'Intensity')) = ...
                    norm([tracks.(A{aa}).(B{bb}).(C{cc}).scaled(end,1) tracks.(A{aa}).(B{bb}).(C{cc}).scaled(end,2)]...
                    - [tracks.(A{aa}).(B{bb}).(C{cc}).scaled(1,1) tracks.(A{aa}).(B{bb}).(C{cc}).scaled(1,2)]);
        
                % Shuff intensity of response (mm)
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sIntensity')) = ...
                    norm([tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(end,1) tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(end,2)]...
                    - [tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(1,1) tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(1,2)]);
        
                % Directionality ratio (straightness)
                d = hypot(diff(tracks.(A{aa}).(B{bb}).(C{cc}).scaled(:,1)), diff(tracks.(A{aa}).(B{bb}).(C{cc}).scaled(:,2))) ;
                distTrav = sum(d);
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'DR')) = ...
                    resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'Intensity'))/distTrav;
                
                % Shuff Directionality ratio (straightness)
                d = hypot(diff(tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(:,1)), diff(tracks.(A{aa}).(B{bb}).(C{cc}).shuffled(:,2))) ;
                SdistTrav = sum(d);
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sDR')) = ...
                    resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sIntensity'))/SdistTrav;
        
                % Average speed (mm/s)
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'AvgSpeed')) = ...
                    distTrav/length(tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho);
        
                % Shuff average speed (mm/s)
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'sAvgSpeed')) = ...
                    SdistTrav/length(tracks.(A{aa}).(B{bb}).(C{cc}).scaled_rho);
    
                %Displacement cosines
                resultados.(A{aa}).(B{bb})(cc,strcmp(stat_names(:), 'dispCos')) = ...
                    cos(tracks.(A{aa}).(B{bb}).(C{cc}).theta(end));
        
                [A{aa} ' ' B{bb} 'nº' num2str(cc) ' runtime was ' num2str(toc) ' seconds']
            end
        end
    
        [A{aa} ' runtime was ' num2str(toc(scenariotime)) ' seconds']
    
    end
    
    close(bar1,bar2,bar3)
  
    ['Calculations section runtime FINISHED in ' num2str(toc(tCalcSec)) ' seconds']

    %Create table with all results data
    T442=enu.resultstruct2table(resultados,stat_names);

    %Export results to .xlsx file
    % enu.results2excel(resultados,stat_names)
    
    %Save data
    save('numericalResults.mat', 'resultados', 'T442') ;

end