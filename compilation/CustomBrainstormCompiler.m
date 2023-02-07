classdef CustomBrainstormCompiler < handle
    
    methods (Access = public)
        
        function compile(obj, withPlugIns)
            arguments
                obj
                withPlugIns = 0
            end
            
            if ~obj.isJavaHomeSet()
                obj.setJavaHomeToPointToJavaOpenJDK();
            end
            foldersToCompile = obj.getFoldersToCompile();
            destinationFolder = fullfile(PathsGetter.getBrainstorm3Path(), "toolbox");
            Copier.Copy(foldersToCompile, destinationFolder);

            if ~obj.isMatlabMccOnSystemPath()
                error(obj.getInstructionsToAddMatlabMccToSystemPath());
            end
            
            if withPlugIns
                obj.compileBrainstorm();
            else
                obj.compileBrainstormNoPlugs();
            end
            
            binFiles = obj.getBinFiles();
            binDestination = obj.getBstBinDestination();
            Copier.Copy(binFiles, binDestination);
            
            obj.deleteCopiedFiles();
            
        end
        
    end
    
    methods (Static, Access = private)

        function setJavaHomeToPointToJavaOpenJDK()
            %java_home = uigetdir('', 'Select OpenJDK folder (jdk***)');
            java_home = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/openJDK/jdk8u322-b06/';
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
        
        function deleteCopiedFiles()
            uigetfile(fullfile(PathsGetter.getBrainstorm3Path(), 'toolbox'));
        end

        function compileBrainstormNoPlugs()            
            brainstorm compile noplugs;            
        end

        function compileBrainstorm()            
            brainstorm compile;            
        end
        
        function bool = isMatlabMccOnSystemPath()
            bool = ~system('command -v mcc');
        end
        
        function instructions = getInstructionsToAddMatlabMccToSystemPath()
            command = 'export PATH=$PATH:/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/MATLAB/bin/';
            step1 = ['<strong>Step 1</strong>. Execute following command in system terminal:' newline command];
            step2 = '<strong>Step 2</strong>. Close and re-open MATLAB';
            instructions = [step1 newline step2];
        end
        
    end
    
end