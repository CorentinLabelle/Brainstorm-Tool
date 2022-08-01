classdef CustomBrainstormCompiler < handle
    
    methods (Access = public)
        
        function compile(obj)
            
            obj.setJavaHome();
            
            %toolFolderSources = PathsGetter.getPaths();
            toolFolderSources = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/domaine';
            Launcher.startBrainstorm();
            %destinationFolder = obj.getDestinationFolder();
            destinationFolder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/Brainstorm_Corentin/brainstorm3/toolbox';
            obj.copyToDestination(toolFolderSources, destinationFolder);

            obj.compileBrainstorm();
            
            binFiles = obj.getBinFiles();
            binDestination = obj.getBinDestination();
            obj.copyToDestination(binFiles, binDestination);
            
        end
        
    end
    
    methods (Static, Access = private)
       
        function binDestination = getBinDestination()
            
            brainstorm3Path = bst_get('BrainstormHomeDir');
            binDestination = fullfile(brainstorm3Path, "bin", bst_get('MatlabReleaseName'));
            
        end
        
        function binFiles = getBinFiles()
            
            brainstorm3Path = bst_get('BrainstormHomeDir');
            
            binFolder = fullfile(brainstorm3Path, "bin", "R2020a");
            bstShellScriptPath = fullfile(binFolder, "brainstorm3.command");
            bstBatchFilePath = fullfile(binFolder, "brainstorm3.bat");
            binFiles = [bstBatchFilePath, bstShellScriptPath]; 
            
        end
        
        function destinationFolder = getDestinationFolder()
            
            brainstorm3Path = bst_get('BrainstormHomeDir');
            destinationFolder = fullfile(brainstorm3Path, "toolbox");
            
        end
    
        function setJavaHome()
            
            setenv('JAVA_HOME', '/usr/lib/jvm/java-8-openjdk-amd64');
            
        end
        
        function copyToDestination(filesToCopy, destinationFolder)
            arguments
                filesToCopy string
                destinationFolder
            end
            
            for i = 1:length(filesToCopy)
                
                folderName = char.empty();
                if isfolder(filesToCopy(i))
                    [~, folderName] = fileparts(filesToCopy(i));
                end
    
                [status, msg] = copyfile(filesToCopy(i), fullfile(destinationFolder, folderName));

                if ~status
                    error(['Error when copying file: ' msg]);
                end

            end
            
        end
        
        function compileBrainstorm()
            
            addpath(genpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/Brainstorm_Corentin/brainstorm3'));
            bst_compile;
            
        end
        
    end
    
end

