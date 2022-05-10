classdef Controller < handle
    
    properties (Access = public)
        
        % Paths
        PathsToAdd = ["/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/domaine", ...
                            "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/interface"
                            ];
                          
        CurrentPipeline; % [Pipeline]
        PipelineSearchPath; % [char]
        RawDataSearchPath; % [char]
        BsToolboxPath = "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3/";
        Type; % [char] EEG/MEG
        
    end
    
    methods (Access = public)
        
        function obj = Controller()
            
            obj.addPaths();
            obj.CurrentPipeline = Pipeline();
            
        end
        
        function startBrainstorm(obj)
           
            addpath(obj.BsToolboxPath);
            
            % Start Brainstorm without interface
            if ~brainstorm('status')
                brainstorm nogui;
            end
            
        end
        
        function switchType(obj, type)
           
            obj.Type = type;
            
        end
        
        function type = getType(obj)
        
            type = obj.Type;
            
        end
        
        function addPaths(obj)
            
            for i = 1:length(obj.PathsToAdd)
                addpath(genpath(obj.PathsToAdd(i)));
            end
            
        end
        
        function removePaths(obj)
            
            for i = 1:length(obj.PathsToAdd)
                rmpath(genpath(obj.PathsToAdd(i)));
            end
            
        end
        
        function process = createProcess(obj, name, structure)
            
            if strcmp(obj.Type, 'EEG')
                process = EEG_Process(name);
                
            elseif strcmp(obj.Type, 'MEG')
                process = MEG_Process(name);
                    
            end
            
            process.asgParameterStructure(structure);
            
        end
        
        function loadPipeline(obj, file)
            
           obj.CurrentPipeline = Pipeline(file);
            
        end
        
        function clearPipeline(obj)
           
            obj.CurrentPipeline = Pipeline();
            
        end
        
        function asgPipelineSearchPath(obj, path)
            
           obj.PipelineSearchPath = path;
            
        end
        
        function path = getPipelineSearchPath(obj)
            
           path = obj.PipelineSearchPath;
            
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
        
    end
end

