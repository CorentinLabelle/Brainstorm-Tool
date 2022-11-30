classdef SpecificProcessDatabase < ClassDatabaseAbstract
  
    properties (SetAccess = protected, GetAccess = public)
        Class;
    end
    
    methods (Access = public)
        
        function obj = SpecificProcessDatabase()
            obj.Class = ProcessClass.SpecificProcess;
            obj.ProcessNames = LoadSpecificProcessInfos();
        end
        
    end
    
end