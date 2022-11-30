classdef ClassDatabaseAbstract
       
    properties (Abstract, SetAccess = protected, GetAccess = public)
        Class;
    end
    
    properties (SetAccess = protected, GetAccess = public)
        ProcessNames cell
    end
    
    methods (Access = ?Database)
        
        function processClass = getProcessClass(obj)
            processClass = obj.Class;
        end
        
        function processNames = getProcessNames(obj)
            processNames = obj.ProcessNames(:, 1);
        end
        
        function isIn = isProcessInDatabase(obj, processName)
            processName = Process.formatProcessName(processName);
            allProcess = obj.getProcessNames();
            isIn = any(cellfun(@(x) strcmpi(x, processName), allProcess));
        end
        
        function processDetails = getProcessDetails(obj, processName)
            index = obj.getProcessIndex(processName);
            processDetails = obj.ProcessNames{index, 2};
        end
        
        function listOrParameters = getListOfParameters(obj, processName)
            index = obj.getProcessIndex(processName);
            listOrParameters = obj.ProcessNames{index, 3};
        end
        
    end
    
    methods (Access = private)
        
        function index = getProcessIndex(obj, processName)
            processName = Process.formatProcessName(processName);
            allProcess = obj.getProcessNames();
            index = find(cellfun(@(x) strcmpi(x, processName), allProcess));
        end
        
    end
    
end