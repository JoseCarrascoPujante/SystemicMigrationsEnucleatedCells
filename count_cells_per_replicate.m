function struct = count_cells_per_replicate(struct, root)
    if nargin < 2
        root = inputname(1);
    end
    
    names = fieldnames(struct);
    for i=1:length(names)
        
        value = struct.(names{i});
        if isstruct(value)
            if contains(fieldnames(struct),'replicate')
                disp(length(fieldnames(value)))
            end
            struct.(names{i}) = count_cells_per_replicate(value, [root '.' names{i}]);
        end
    end
end