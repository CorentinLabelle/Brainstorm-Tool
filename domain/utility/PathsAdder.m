classdef PathsAdder
    
    methods (Static, Access = public)
        
        function addPaths()            
            paths = PathsGetter.getPathsToAdd();            
            if ~isdeployed()
                for i = 1:length(paths)
                    addpath(genpath(paths(i)));
                end
            end            
            addpath(PathsGetter.getBstToolFolder());
            PathsAdder.addBrainstorm3Path();
        end
        
        function [isAdded, bst3Folder] = addBrainstorm3Path()
            if PathsGetter.isBrainstorm3FolderInMatlabPath()
                warning('brainstorm3 path already added.');
                return
            end            
            %bst3Folder = uigetdir(pwd, 'Select brainstorm3 folder');
            bst3Folder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3';
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