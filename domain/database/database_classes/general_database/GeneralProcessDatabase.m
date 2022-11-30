classdef GeneralProcessDatabase < ClassDatabaseAbstract
  
    properties (SetAccess = protected, GetAccess = public)
        Class;
    end
    
    methods (Access = public)
        
        function obj = GeneralProcessDatabase()
            obj.Class = ProcessClass.GeneralProcess;
            obj.ProcessNames = LoadGeneralProcessInfos();
        end
        
    end
    
end