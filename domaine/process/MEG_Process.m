classdef (InferiorClasses = {?GeneralProcess, ?SpecificProcess, ?Process}) ...
        MEG_Process < Process
    
    properties (Constant, Access = private)
        
        Type = "meg";
        
    end
    
    methods (Access = {?ProcessFactory, ?ProcessConverter})
        
        function obj = MEG_Process()
        end
        
    end
    
    methods (Static, Access = ?Process)
        
        function analyzer = getAnalyzer()
        
            analyzer = MEG_Analyzer.instance;
            
        end
        
    end
    
    methods (Static, Access = public)
       
        function type = getType()
           
            type = eval([mfilename('class') '.Type']);

        end
        
    end
    
end