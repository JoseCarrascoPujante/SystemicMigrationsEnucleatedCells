function tracks=swapfields(tracks)
    A = fieldnames(tracks);
    for aa = 1:length(A)
        B = fieldnames(tracks.(A{aa}));
        for bb = 1:length(B)
            C=fieldnames(tracks.(A{aa}).(B{bb}));
            for cc = 1:length(C)
                D = fieldnames(tracks.(A{aa}).(B{bb}).(C{cc}));
                for dd = 1:length(D)
                        tracks.(A{aa}).(B{bb}).(D{dd}).(C{cc}) = tracks.(A{aa}).(B{bb}).(C{cc}).(D{dd});
                end
            end
            tracks.(A{aa}).(B{bb}) = rmfield(tracks.(A{aa}).(B{bb}),C);
        end
    end
end