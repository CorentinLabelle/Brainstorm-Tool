classdef ControllerPipelineBuilder < handle
    
    properties
        CurrentPipeline Pipeline;
        PipelineSearchPath char;
        BidsSearchPath char;
        RawDataSearchPath char;
    end
    
    methods
        
        function obj = ControllerPipelineBuilder()
            
            obj.CurrentPipeline = Pipeline();
            
        end
        
        function addProcess(obj, name, structure)
            
            a = EEG_Process(name);
            a.addParameterStructure(structure);
            obj.CurrentPipeline.addProcess(a);
            
        end
        
        function asgPipelineFolder(obj, folder)
           
            obj.CurrentPipeline.asgFolder(folder);
            
        end
        
        function asgPipelineName(obj, name)
           
            obj.CurrentPipeline.asgName(name);
            
        end
        
        function asgPipelineExtension(obj, extension)
           
            obj.CurrentPipeline.asgExtension(extension);
            
        end
        
        function asgPipelineType(obj, type)
           
            obj.CurrentPipeline.asgType(type);
            
        end
        
        function clearPipeline(obj)
           
            obj.CurrentPipeline = Pipeline();
            
        end
        
        function savePipeline(obj)
            
            obj.CurrentPipeline.save();
            
        end
        
        function loadPipeline(obj, file)
            
           obj.CurrentPipeline = Pipeline(file);
            
        end
        
        function asgPipelineSearchPath(obj, path)
            
           obj.PipelineSearchPath = path;
            
        end
        
        function path = getPipelineSearchPath(obj)
            
           path = obj.PipelineSearchPath;
            
        end
        
        function asgBidsSearchPath(obj, path)
            
           obj.BidsSearchPath = path;
            
        end
        
        function path = getBidsSearchPath(obj)
            
           path = obj.BidsSearchPath;
            
        end
        
        function asgRawDataSearchPath(obj, path)
            
           obj.RawDataSearchPath = path;
            
        end
        
        function path = getRawDataSearchPath(obj)
            
           path = obj.RawDataSearchPath;
            
        end
        
        function pipeline = getPipeline(obj)
            
            pipeline = obj.CurrentPipeline;
            
        end
        
        function test(obj)
           
            persistent a;
            
            if isempty(a)
                a = 0;
            else
                a = a + 1;
            end
            
        end
    end
end

