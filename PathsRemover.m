classdef PathsRemover
    
    methods (Static, Access = public)
        
        function removePaths()
            
            paths = PathsGetter.getPaths();
            
            if ~isdeployed()
                for i = 1:length(paths)
                    rmpath(genpath(paths(i)));
                end
            end
            
        end
        
    end
end