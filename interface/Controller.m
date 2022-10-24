classdef Controller < handle
    
    properties (Access = protected)

        CurrentPipeline;
        PipelineSearchPath string;
        RawDataSearchPath string;
        Type;
    
    end
    
    methods (Access = public)
        
        function obj = Controller()
            
            obj.CurrentPipeline = Pipeline();
            
        end
        
        function switchType(obj, type)
           
            obj.Type = type;
            
        end
        
        function type = getType(obj)
        
            type = obj.Type;
            
        end
        
        function process = createProcess(obj, name, structure)
            
            arguments
                obj
                name (1,1) string {mustBeNonempty}
                structure struct = struct.empty();
            end
            
            process = Process.create(name);
            
            if ~isempty(structure)
                process.setParameterWithStructure(structure);
            end
            
        end
        
        function loadPipeline(obj, file)            
           obj.CurrentPipeline = Pipeline(file);            
        end
        
        function clearPipeline(obj)           
            obj.CurrentPipeline = Pipeline();            
        end
        
        function setPipelineSearchPath(obj, path)            
           obj.PipelineSearchPath = path;            
        end
        
        function path = getPipelineSearchPath(obj)            
           path = obj.PipelineSearchPath;            
        end
        
        function setRawDataSearchPath(obj, path)            
           obj.RawDataSearchPath = path;            
        end
        
        function path = getRawDataSearchPath(obj)            
           path = obj.RawDataSearchPath;            
        end
        
        function pipeline = getPipeline(obj)            
            pipeline = obj.CurrentPipeline;            
        end
                
        function extensions = getPipelineSupportedExtensionToGetFile(obj)            
            extensions = strcat('*', obj.getPipelineSupportedExtension)';        
        end
                
        function supportedExtension = getPipelineSupportedExtension(obj)           
            supportedExtension = obj.CurrentPipeline.getSupportedExtension;            
        end

        function datasetFormat = getSupportedDatasetFormatToGetFile(obj)            
            datasetFormat = strcat('*', obj.getSupportedDatasetFormat)';        
        end
        
        function datasetFormat = getSupportedDatasetFormat(obj)            
            datasetFormat = GetDatasetExtension(obj.Type);           
        end
       
        function linkOfLastReport = getLinkOfLastReport(obj)           
            linkOfLastReport = obj.CurrentPipeline.getLinkOfLastReport();            
        end
        
    end
    
    methods
       
        function set.Type(obj, type)            
            obj.Type = lower(type);            
        end
        
    end
    
end