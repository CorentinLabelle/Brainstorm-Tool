classdef PathsGetter    
    
    methods (Static, Access = public)
        
        function bstToolFolder = getBstToolFolder()           
            bstToolFolder = GetBrainstormToolFolder();            
        end
        
        function databaseFolder = getBstDatabaseFolder()           
            databaseFolder = bst_get('BrainstormDbDir');            
        end
        
        function domainFolder = getDomainFolder()            
            domainFolder = fullfile(PathsGetter.getBstToolFolder(), "domaine");            
        end
        
        function interfaceFolder = getInterfaceFolder()           
            interfaceFolder = fullfile(PathsGetter.getBstToolFolder(), "interface");            
        end
        
        function autoToolFolder = getAutomatedToolFolder()           
            autoToolFolder = fullfile(PathsGetter.getBstToolFolder(), "automatedTool");            
        end
        
        function compilationFolder = getCompilationFolder()           
            compilationFolder = fullfile(PathsGetter.getBstToolFolder(), "compilation");            
        end 
        
        function testFolder = getTestFolder()           
            testFolder = fullfile(PathsGetter.getBstToolFolder(), "tests");            
        end 
        
        function bstFolder = getBstFolder()           
            bstFolder = fullfile(PathsGetter.getBstToolFolder(), "Brainstorm_EEGNET");            
        end
            
        function mcrFolder = getMcrFolder()            
            if isunix
                mcrFolder = '/usr/local/MATLAB/MATLAB_Runtime';
            elseif ispc
                mcrFolder = 'C:\Program Files\MATLAB\MATLAB Runtime';
            elseif ismac
                mcrFolder = '/Applications/MATLAB/MATLAB_Runtime';
            end            
            if ~isfolder(mcrFolder)
                mcrFolder = uigetdir('*', 'Select Runtime folder');
            end            
        end
        
        function paths = getPathsToAdd()            
            paths = [   PathsGetter.getDomainFolder(), ...
                        PathsGetter.getInterfaceFolder(), ...
                        PathsGetter.getAutomatedToolFolder(), ...
                        PathsGetter.getCompilationFolder(), ...
                        PathsGetter.getTestFolder() ...
                        ];            
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
    
end