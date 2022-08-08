classdef ProcessLoader
    
    methods (Static, Access = ?ProcessDefaultInfoGetter)
        
        function allProcesses = loadDefaultProcesses()
            
            allProcesses = defaultProcesses();
            
        end
        
    end
    
end