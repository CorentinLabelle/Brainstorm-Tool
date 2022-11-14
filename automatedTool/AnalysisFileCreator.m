classdef AnalysisFileCreator < handle
    
    properties (Access = private)
        JsonStructure = struct();
    end
    
    methods (Access = public)
        
        function obj = AnalysisFileCreator()
        end
        
        function setProtocol(obj, protocol)
            obj.JsonStructure.Protocol = protocol;
        end
        
        function setSFile(obj, sFile)
            if ~isempty(sFile)
                sFile = {sFile.FileName};
            end
            obj.JsonStructure.Dataset = sFile;
        end
        
        function setPipeline(obj, pipeline)
            pipelinePath = pipeline.getPath('.json');
            obj.setPipelinePath(pipelinePath);
        end
        
        function setPipelinePath(obj, pipelinePath)
            obj.JsonStructure.Pipeline = pipelinePath;
        end
        
        function path = createAnalysisFile(obj, path)
            FileSaver.save(path, obj.JsonStructure);
        end
        
    end
    
end