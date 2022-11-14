classdef Database
    
    properties (SetAccess = private, GetAccess = public)
        ClassDatabase cell
    end
    
    methods (Access = public)
        
        function obj = Database()
            obj.ClassDatabase = Database.loadClassDatabase(); 
        end
        
        function processNamesByProcessClass = getProcessNames(obj)
            processNamesByProcessClass = struct();
            for i = 1:length(obj.ClassDatabase)
               processClassName = char(obj.ClassDatabase{i}.getProcessClass());
               processNamesByProcessClass.(processClassName) = obj.ClassDatabase{i}.getProcessNames();
            end
        end
        
        function processCls = getProcessClass(obj, processName)
            classDatabase = obj.getClassDatabaseWithProcessName(processName);
            processCls = classDatabase.getProcessClass();
        end
        
        function processDetails = getProcessDetails(obj, processName)
            classDatabase = obj.getClassDatabaseWithProcessName(processName);
            processDetailsFctHdl = classDatabase.getProcessDetails(processName);
            processDetails = processDetailsFctHdl();
        end
        
        function listOfParameters = getListOfParameters(obj, processName)
            classDatabase = obj.getClassDatabaseWithProcessName(processName);
            listOfParameters = classDatabase.getListOfParameters(processName);
        end
        
    end
    
    methods (Access = private)
        
        function classDatabase = getClassDatabaseWithProcessName(obj, processName)
            processName = Process.formatProcessName(processName);
            indexes = cellfun(@(x) x.isProcessInDatabase(processName), obj.ClassDatabase);
            if ~any(indexes)
               error(['The process name is invalid (' char(processName) ').']);
            end
            classDatabase = obj.ClassDatabase{indexes};
        end
        
    end
    
    methods (Static, Access = private)
        
        function classDatabase = loadClassDatabase()
            classDatabase = {...
                            GeneralProcessDatabase(), ...
                            EegProcessDatabase(), ...
                            SpecificProcessDatabase()};
        end
        
    end
    
end