classdef PathsGetter
    
    methods (Static, Access = public)
        
        function paths = getPaths()
            
            folder = "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool";
            folderNames = ["domaine", "interface", "automatedTool", "compilation", "tests"];
            paths = fullfile(folder, folderNames);
            %paths = [paths, PathsGetter.getCurrentFileFolder()];
            
        end
        
        function isIn = isBrainstorm3FolderInMatlabPath()
           
            [~, foldersInSearchPaths] = fileparts(regexp(path, pathsep, 'Split'));
            isIn = any(strcmp('brainstorm3', foldersInSearchPaths));
            
        end
       
        function brainstorm3Path = getBrainstorm3Path()
           
            if PathsGetter.isBrainstorm3FolderInMatlabPath()
                allPaths = regexp(path, pathsep, 'Split');
                [~, foldersInSearchPaths] = fileparts(allPaths);
                idx = strcmp('brainstorm3', foldersInSearchPaths);
                brainstorm3Path = allPaths{idx};
            else
                [~, brainstorm3Path] = PathsAdder.addBrainstorm3Path();
            end
            
        end
        
    end
    
    methods (Static, Access = private)
       
        function folder = getCurrentFileFolder()
           
            folder = fileparts(mfilename('fullpath'));
            
        end
        
    end
    
end