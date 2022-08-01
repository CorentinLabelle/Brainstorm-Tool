classdef (InferiorClasses = {?SpecificProcess, ?Process}) GeneralProcess < Process
    
    properties (Constant, Access = private)
        
        Type = "general";
        
    end
    
    methods (Access = {?ProcessFactory, ?ProcessConverter})
        
        function obj = GeneralProcess()
        end
        
    end
    
    methods (Static, Access = ?Process)
        
        function analyzer = getAnalyzer()
        
            analyzer = Analyzer.instance;
            
        end
        
    end
    
    methods (Static, Access = public)
       
        function type = getType()
           
            type = eval([mfilename('class') '.Type']); 
        
        end
        
    end
    
end