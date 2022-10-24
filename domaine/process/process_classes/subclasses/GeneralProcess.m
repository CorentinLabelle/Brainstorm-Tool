classdef GeneralProcess < Process
    
    methods (Access = ?ProcessClass)
        
        function obj = GeneralProcess()
        end
        
    end
    
    methods (Static, Access = ?Process)
        
        function analyzer = getAnalyzer()        
            analyzer = BstFunctions.instance;            
        end
        
    end
    
end