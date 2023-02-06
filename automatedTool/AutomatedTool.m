classdef AutomatedTool < handle
    
    methods (Access = public)
                
        function outputPath = run(obj, jsonFile)            
            assert(~isempty(jsonFile), 'No file to run!');
            
            analysisFileReader = AnalysisFileReader(jsonFile);
            protocolName = analysisFileReader.getProtocol();
            sFiles = analysisFileReader.getSFile();
            pipeline = analysisFileReader.getPipeline();
            
            if isempty(sFiles)
                assert(pipeline.isProcessInPipelineWithName('review raw files'));
            end
            pipeline = obj.addImportTimeProcess(pipeline);
            obj.verifyPipeline(pipeline, protocolName);
            
            if ProtocolManager.isProtocolCreated(protocolName)
                ProtocolManager.setProtocol(ProtocolManager.getProtocolIndex(protocolName));
            else
                ProtocolManager.createProtocol(protocolName);
            end
            
            [~, sFilesOut] = pipeline.run(sFiles);
            outputPath = obj.createOuputPath(jsonFile);
            obj.createJsonOutput(outputPath, sFilesOut);            
        end
        
    end
    
    methods (Static, Access = public)
  
        function instruction = getCommandLineInstructionToRunAsDeployed(jsonFile)
            arguments
                jsonFile = char.empty();
            end
            
            runAutomatedToolScript = AutomatedTool.getPathToScriptToRunAutomatedTool();
            
            binFolder = fullfile(PathsGetter.getBrainstorm3Path(), 'bin', char(matlabRelease.Release));
            if ~isfolder(binFolder)
                error('The bin folder does not exist. You have to compile the tool!');
            end

            if ispc
                batchFile = fullfile('/', binFolder, 'brainstorm3.bat');
                matlabRoot = '';
            elseif ismac || isunix
                batchFile = fullfile('/', binFolder, 'brainstorm3.command');
                matlabRoot = PathsGetter.getMcrFolder();
            end
            
            instruction = [batchFile ' ' matlabRoot ' ' runAutomatedToolScript ' ' jsonFile];            
        end
        
    end
    
    methods (Static, Access = private)
        
        function verifyPipeline(pipeline, protocolName)           
            if ~ProtocolManager.isProtocolCreated(protocolName)
                assert(pipeline.isProcessInPipelineWithName('create_subject'), 'You have to create a subject');
            end            
        end
        
        function pipeline = addImportTimeProcess(pipeline)
            processNames = 'import_time';
            if ~pipeline.isProcessInPipelineWithName(processNames)
                pipeline = pipeline.addProcess(Process.create(processNames));
            end            
        end
        
        function outputPath = createJsonOutput(outputPath, sFilesOut)            
            FileSaver.save(outputPath, sFilesOut);            
        end
        
        function outputPath = createOuputPath(jsonFile)           
            [folder, filename] = fileparts(jsonFile);
            outputPath = strcat(fullfile(folder, filename), '_output.json');            
        end
        
        function filePath = getPathToScriptToRunAutomatedTool()
            filePath = fullfile(GetBrainstormToolFolder(), 'automatedTool', 'runAutomatedTool.m');
        end
        
    end
    
end