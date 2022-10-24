classdef EegProcess < Process
    
    methods (Access = ?ProcessClass)
        
        function obj = EegProcess()
        end
        
    end
    
    methods (Static, Access = public)
        
        function analyzer = getAnalyzer()
            analyzer = BstEegFunctions.instance;
        end
        
    end
    
end