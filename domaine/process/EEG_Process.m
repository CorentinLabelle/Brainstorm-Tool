classdef (InferiorClasses = {?GeneralProcess, ?SpecificProcess, ?Process}) ...
        EEG_Process < Process
    
    properties (Constant, Access = private)
        
        Type = "eeg";
        
    end
    
    methods (Access = {?ProcessFactory, ?ProcessConverter})
        
        function obj = EEG_Process()
        end
        
    end
    
    methods (Static, Access = ?Process)
        
        function analyzer = getAnalyzer()
        
            analyzer = EEG_Analyzer.instance;
            
        end
        
    end
    
    methods (Static, Access = public)
       
        function type = getType()
           
            type = eval([mfilename('class') '.Type']);   
            
        end
        
    end
    
end