classdef AutomatedTool < handle
    
    methods (Access = public)
                
        function sFilesOut = run(obj, jsonFile)
            
            assert(~isempty(jsonFile), 'No file to run!');
            obj.verifyFileExtension(jsonFile);
            
            structure = FileReader.read(jsonFile);
            protocolName = obj.getProtocolName(structure);
            sFiles = obj.getsFiles(structure);
            pipeline = obj.getPipeline(structure);
            
            if isempty(sFiles)
                assert(pipeline.isProcessInPipelineWithName('review raw files'));
            end
            
            if ~pipeline.isProcessInPipelineWithName('import_time')
               pipeline.addProcess(Process.create('import_time'));
            end
            
            obj.verifyPipeline(pipeline, protocolName);
            
            if ProtocolManager.isProtocolCreated(protocolName)
                ProtocolManager.setProtocol(ProtocolManager.getProtocolIndex(protocolName));
            else
                ProtocolManager.createProtocol(protocolName);
            end
            
            sFilesOut = pipeline.run(sFiles);
            
        end
        
    end
    
    methods (Static, Access = public)
  
        function [baseDirectory, instruction] = getCommandLineInstructionToRunAsDeployed(jsonFile)
            arguments
                jsonFile = char.empty();
            end
            
            runAutomatedToolScript = AutomatedTool.getPathToScriptToRunAutomatedTool();
            
            binFolder = fullfile(PathsGetter.getBrainstorm3Path(), 'bin', char(matlabRelease.Release));
            if ~isfolder(binFolder)
                error('The bin folder does not exist. You have to compile the tool!');
            end

            if ispc
                batchFile = 'brainstorm3.bat';
                matlabRoot = '';
            elseif ismac || isunix
                batchFile = fullfile(binFolder, 'brainstorm3.command');
                matlabRoot = PathsGetter.getMcrFolder();
                %matlabRoot = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/MATLAB/MATLAB_Runtime/v98/';
            end

            baseDirectory = binFolder;
            instruction = [batchFile ' ' matlabRoot ' ' runAutomatedToolScript ' ' jsonFile];
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function protocolName = getProtocolName(structure)
            
            if isfield(structure, 'Protocol')
                protocolName = structure.Protocol;
            else
                error('You need to enter a protocol');
            end
            
        end
        
        function sFiles = getsFiles(structure)
            
            if isfield(structure, 'sFiles')
                sFiles = structure.sFiles;
            else
                sFiles = [];
            end
            
        end
        
        function pipeline = getPipeline(structure)
           
            if isfield(structure, 'Pipeline')
                pipeline = Pipeline(structure.Pipeline);
            else
                error('You need to enter a protocol');
            end
            
        end
        
        function verifyFileExtension(filePath)
            
            [~, ~, extension] = fileparts(filePath);
            assert(strcmpi(extension, '.json'));
            
        end
        
        function verifyPipeline(pipeline, protocolName)
           
            if ~ProtocolManager.isProtocolCreated(protocolName)
                assert(pipeline.isProcessInPipelineWithName('create_subject'), ...
                    'You have to create a subject');
            end
            
        end
        
        function filePath = getPathToScriptToRunAutomatedTool()
           
            filePath = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/automatedTool/runAutomatedTool.m';
            
        end
        
    end
    
end