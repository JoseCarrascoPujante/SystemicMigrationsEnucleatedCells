% Copyright (c) 2011 Thomas Schaffter
%
% Author: Thomas Schaffter (firstname.name@gmail.com)
% Version: June 15, 2011
%
% UNFOLD_STRUCTURE Unfold and show the content of the given structure.
%    UNFOLD_STRUCTURE(STRUCT) shows recursively the content of the
%    given structure STRUCT. Clean and generic implementation which
%    can be easily extended, e.g. for structures containing cells.
%
%    Usage: unfold_structure(myStructure);
%
function struct = structchanger(struct, root)
    if nargin < 2
        root = inputname(1);
    end
    
    names = fieldnames(struct);
    for i=1:length(names)
        
        value = struct.(names{i});
        if isstruct(value)
            struct.(names{i}) = enu.structchanger(value, [root '.' names{i}]);
        else
            disp([root '.' names{i}]);
            if isa(value,'double') && names{i} ~= "scaled"
                struct = rmfield(struct,(names{i}));              
            end
        end
    end
    if isa(value,'double')
        z = struct2cell(struct);
        struct = cell2struct(z,'xy');      
    end
end