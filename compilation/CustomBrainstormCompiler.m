classdef CustomBrainstormCompiler < handle
    
    methods (Access = public)
        
        function compile(obj)
            
            obj.setJavaHomeToPointToJavaOpenJDK();
            
            domainFolder = PathsGetter.getDomainFolder();
            autoToolFolder = PathsGetter.getAutomatedToolFolder();
            foldersToCopy = [domainFolder, autoToolFolder];
            destinationFolder = fullfile(PathsGetter.getBrainstorm3Path(), "toolbox");
            obj.copyToDestination(foldersToCopy, destinationFolder);

            obj.compileBrainstorm();
            
            binFiles = obj.getBinFiles();
            binDestination = obj.getBstBinDestination();
            obj.copyToDestination(binFiles, binDestination);
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function binDestination = getBstBinDestination()
            
            brainstorm3Path = PathsGetter.getBrainstorm3Path();
            binDestination = fullfile(brainstorm3Path, "bin", bst_get('MatlabReleaseName'));
            
        end
        
        function binFiles = getBinFiles()
            
            brainstorm3Path = PathsGetter.getBrainstorm3Path();
            
            binFolder = fullfile(brainstorm3Path, "bin", "R2020a");
            bstShellScriptPath = fullfile(binFolder, "brainstorm3.command");
            bstBatchFilePath = fullfile(binFolder, "brainstorm3.bat");
            binFiles = [bstBatchFilePath, bstShellScriptPath]; 
            
        end
            
        function setJavaHomeToPointToJavaOpenJDK()
            
            if isunix
                openJdkFolder = '/usr/lib/jvm/java-8-openjdk-amd64';
            elseif ispc
                openJdkFolder = 'C:\Users\alab\Desktop\OpenJDK8U-jdk_x64_windows_hotspot_8u332b09\jdk8u332-b09';
            elseif ismac
                error('add path to openjdk');
            end
              
            assert(isfolder(openJdkFolder));
            setenv('JAVA_HOME', openJdkFolder);
            
        end
        
        function copyToDestination(filesToCopy, destinationFolder)
            arguments
                filesToCopy string
                destinationFolder string
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
            
            bst_compile;
            
        end
        
    end
    
end