function ApEnLoop(tracks,destination_folder)
    
    step = 82;

    AE.Cells = [NaN(200,4100/step)];
    AE.sCells = [NaN(200,4100/step)];
    AE.Cytoplasts = [NaN(200,4100/step)];
    AE.sCytoplasts = [NaN(200,4100/step)];

    bar1 = waitbar(0,'init.','Name','scenario') ;
    bar1.Children.Title.Interpreter = 'none';
    bar2 = waitbar(0,'init.','Name','experiment') ;
    bar2.Children.Title.Interpreter = 'none';
    bar3 = waitbar(0,'init.','Name','track') ;
    bar3.Children.Title.Interpreter = 'none';
    bar4 = waitbar(0,'init.','Name','step') ;
    bar4.Children.Title.Interpreter = 'none';    
    
    trackcount.Cells = 0;
    trackcount.Cytoplasts = 0;

    I = fieldnames(tracks); 
    for ii = 1:length(I) % nº scenarios
        bar1 = waitbar(ii/length(I), bar1, I{ii}) ;
        J = fieldnames(tracks.(I{ii})) ;
        if contains(I{ii},'_Cells')
            condition = 'Cells';
        elseif contains(I{ii},'_Cytoplasts')
            condition = 'Cytoplasts';
        end            
        
        for jj = 1:length(J) % nº experiments
            bar2 = waitbar(jj/length(J), bar2, J{jj}) ;
            K = fieldnames(tracks.(I{ii}).(J{jj})) ;
            for kk = 1:length(K) % nº tracks
                trackcount.(condition) = trackcount.(condition) + 1;
                bar3 = waitbar(kk/length(K), bar3, K{kk}) ;
                nframes = length(tracks.(I{ii}).(J{jj}).(K{kk}).scaled_rho);

                for ll = step:step:nframes % ApEn calculation
                    bar4 = waitbar(ll/nframes, bar4, ll) ;

                    AE.(condition)(trackcount.(condition),ll/step) = enu.ApEn(2, 0.2*std(tracks.(I{ii}).(J{jj}).(K{kk}).scaled_rho(1:ll)),...
                        tracks.(I{ii}).(J{jj}).(K{kk}).scaled_rho(1:ll)) ;
                    
                    AE.(['s',condition])(trackcount.(condition),ll/step) = enu.ApEn(2, 0.2*std(tracks.(I{ii}).(J{jj}).(K{kk}).shuffled_rho(1:ll)),...
                        tracks.(I{ii}).(J{jj}).(K{kk}).shuffled_rho(1:ll)) ;
                end
            end
        end
        sound(sin(1:8000))
    end

    close(bar1,bar2,bar3,bar4)
    save(strcat(destination_folder,'\','ApEn',num2str(step),'framestep.mat'), 'AE') ;
end