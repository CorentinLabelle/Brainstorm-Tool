classdef MegProcess < Process
    
    methods (Access = ?ProcessClass)
        
        function obj = MegProcess()
        end
        
    end
    
    methods (Static, Access = ?Process)
        
        function analyzer = getAnalyzer()        
            analyzer = BstMegFunctions.instance;            
        end
        
    end
    
end