classdef CustomBrainstormCompiler < handle
    
    methods (Access = public)
        
        function compile(obj)
            if ~obj.isJavaHomeSet()
                obj.setJavaHomeToPointToJavaOpenJDK();
            end
            foldersToCompile = obj.getFoldersToCompile();
            destinationFolder = fullfile(PathsGetter.getBrainstorm3Path(), "toolbox");
            Copier.Copy(foldersToCompile, destinationFolder);

            obj.compileBrainstormNoPlugs();
            
            binFiles = obj.getBinFiles();
            binDestination = obj.getBstBinDestination();
            Copier.Copy(binFiles, binDestination);
        end
        
    end
    
    methods (Static, Access = private)

        function setJavaHomeToPointToJavaOpenJDK()
            java_home = uigetdir('', 'Select OpenJDK folder (jdk***)');
            setenv('JAVA_HOME', java_home);            
        end

        function isSet = isJavaHomeSet()
            java_home = getenv('JAVA_HOME');
            isSet = ~isempty(java_home) && isfolder(java_home);
        end

        function folders = getFoldersToCompile()
            domainFolder = PathsGetter.getDomainFolder();
            automatedToolFolder = PathsGetter.getAutomatedToolFolder();
            folders = [domainFolder, automatedToolFolder];
        end

        function binDestination = getBstBinDestination()
            brainstorm3Path = PathsGetter.getBrainstorm3Path();
            binDestination = fullfile(brainstorm3Path, "bin", matlabRelease.Release);            
        end
        
        function binFiles = getBinFiles()            
            brainstorm3Path = PathsGetter.getBrainstorm3Path();
            binFolder = fullfile(brainstorm3Path, "bin", "R2020a");
            bstShellScriptPath = fullfile(binFolder, "brainstorm3.command");
            bstBatchFilePath = fullfile(binFolder, "brainstorm3.bat");
            binFiles = [bstBatchFilePath, bstShellScriptPath];
        end

        function compileBrainstormNoPlugs()            
            brainstorm compile noplugs;            
        end

        function compileBrainstorm()            
            brainstorm compile;            
        end
        
    end
    
end