classdef AutomatedTool < handle
    
    methods (Access = public)
                
        function outputPath = run(obj, jsonFile)            
            assert(~isempty(jsonFile), 'No file to run!');
            
            analysisFile = AnalysisFile(jsonFile);
            protocolName = analysisFile.getProtocol();
            sFiles = analysisFile.getSFile();
            pipeline = analysisFile.getPipeline();
            
            if isempty(sFiles)
                rrf = pipeline.isProcessInPipelineWithName('review raw files');
                ibd = pipeline.isProcessInPipelineWithName('import bids dataset');
                if ~rrf && ~ibd
                    error('No input data and no process in your pipeline import data...');
                end
            end
            pipeline = obj.addImportTimeProcess(pipeline);
            obj.verifyPipeline(pipeline, protocolName);
            
            if ProtocolManager.isProtocolCreated(protocolName)
                ProtocolManager.setProtocol(ProtocolManager.getProtocolIndex(protocolName));
            else
                ProtocolManager.createProtocol(protocolName);
            end
            
            [~, sFilesOut] = pipeline.run(sFiles);
            outputPath = analysisFile.createOutput(sFilesOut);           
        end
        
    end
    
    methods (Static, Access = private)
        
        function verifyPipeline(pipeline, protocolName)           
            if ~ProtocolManager.isProtocolCreated(protocolName)
                %assert(pipeline.isProcessInPipelineWithName('create_subject'), 'You have to create a subject');
            end            
        end
        
        function pipeline = addImportTimeProcess(pipeline)
            processNames = 'import_time';
            if ~pipeline.isProcessInPipelineWithName(processNames)
                pipeline = pipeline.addProcess(Process.create(processNames));
            end            
        end
        
    end
    
end