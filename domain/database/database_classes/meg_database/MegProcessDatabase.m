classdef MegProcessDatabase < ClassDatabaseAbstract
  
    properties (SetAccess = protected, GetAccess = public)
        Class = ProcessClass.MegProcess;
    end
    
    methods (Access = public)
        
        function obj = MegProcessDatabase()
            obj.Class = ProcessClass.MegProcess;
            obj.ProcessNames = LoadMegProcessInfos();
        end
        
    end
    
end