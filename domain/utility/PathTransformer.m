classdef PathTransformer
    
    methods (Static, Access = public)
        
        function absolutePath = toAbsolute(root, path)
            if ~startsWith(path, '.')
                absolutePath = path;
                return
            end
            while startsWith(path, '.')
                if  startsWith(path, '..')
                    root = PathTransformer.removeLastFolderFromPath(root);
                end
                path = PathTransformer.removeFirstFolderFromPath(path);
            end
            absolutePath = fullfile(root, path);
        end
        
    end
    
    methods (Static, Access = private)
        
        function path = removeLastFolderFromPath(path)
            pathSplit = split(path, filesep);
            path = fullfile('/', pathSplit{1:end-1});
        end

        function path = removeFirstFolderFromPath(path)
            pathSplit = split(path, filesep);
            path = fullfile(pathSplit{2:end});
        end
        
    end
    
end




        
        