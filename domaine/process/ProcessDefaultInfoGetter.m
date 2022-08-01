classdef ProcessDefaultInfoGetter
    
    properties (Access = private)
        
        AllProcesses (1,1) struct;
        
    end
    
    methods (Access = public)
        
        function obj = ProcessDefaultInfoGetter()
           
            obj.AllProcesses = ProcessLoader.loadDefaultProcesses();
            
        end
               
        function allProcesses = getAllProcesses(obj)
            
            allProcesses = obj.AllProcesses;
            
        end
        
        function cls = getPrClsWithType(obj, type)
           
            type = lower(type);
            prSubClasses = string(fieldnames(obj.AllProcesses)');
            
            cls = char.empty();
            for i = 1:length(prSubClasses)
                typeOfCurrentClass = eval([prSubClasses{i} '.getType']);
                if isequal(typeOfCurrentClass, type)
                    cls = prSubClasses{i};
                    break
                end
            end
            
            if isempty(cls)
                error(['The type is invalid (' char(type) ').']);
            end
            
        end
        
        function cls = getPrClsWithPrName(obj, prName)
            
            prName = Process.formatProcessName(prName);
            prSubClasses = string(fieldnames(obj.AllProcesses)');
            
            cls = char.empty();
            for i = 1:length(prSubClasses)
                if isfield(obj.AllProcesses.(prSubClasses{i}), prName)
                    cls = prSubClasses{i};
                    return
                end
            end
            
            if isempty(cls)
                error(['The process name is invalid (' prName ').']);
            end
            
        end
        
        function initializedPrStruct = getInitializedPrStruct(obj, prName)
           
            prName = Process.formatProcessName(prName);
            cls = obj.getPrClsWithPrName(prName);
            initializedPrStruct = obj.AllProcesses.(cls).(prName);
            
        end
        
    end
    
end