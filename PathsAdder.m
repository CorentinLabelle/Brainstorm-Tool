classdef PathsAdder
    
    methods (Static, Access = public)
        
        function addPaths()
            
            paths = PathsGetter.getPathsToAdd();
            
            if ~isdeployed()
                for i = 1:length(paths)
                    addpath(genpath(paths(i)));
                end
            end
            
        end
        
        function [isAdded, bst3Folder] = addBrainstorm3Path()
            
            assert(~PathsGetter.isBrainstorm3FolderInMatlabPath(), ...
                    ['brainstorm3 path already added:' newline PathsGetter.getBrainstorm3Path()]);
            
            bst3Folder = uigetdir(pwd, 'Select brainstorm3 folder');
            if isequal(bst3Folder, 0)
                isAdded = false;
                return
            end

            [~, folderName] = fileparts(bst3Folder);
            expectedFolder = 'brainstorm3';
            if ~strcmpi(folderName, expectedFolder)
                error(  ['Wrong folder (' folderName ...
                        '). Should be ' expectedFolder '.']);
            end

            if ~isdeployed()
                addpath(bst3Folder);
            end
            isAdded = true;

        end
        
    end
end