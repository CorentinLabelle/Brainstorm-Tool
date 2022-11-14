classdef EegProcessDatabase < ClassDatabaseAbstract
  
    properties (SetAccess = protected, GetAccess = public)
        Class = ProcessClass.EegProcess;
    end
    
    methods (Access = public)
        
        function obj = EegProcessDatabase()
            obj.Class = ProcessClass.EegProcess;
            obj.ProcessNames = LoadEegProcessInfos();
        end
        
    end
    
end