classdef (InferiorClasses = ?Process) SpecificProcess < Process
    
    properties (Constant, Access = private)
        
        Type = "specific";
        
    end
    
    methods (Access = {?ProcessFactory, ?ProcessConverter})
        
        function obj = SpecificProcess()
        end
        
    end
    
%     methods (Static, Access = ?Process)
%         
%         function analyzer = getAnalyzer()
%         
%             analyzer = Analyzer.empty();
%             error([ 'No analyzer available for specific process. '...
%                     'Cast your process with the function: processName.castWithType(''eeg'')']);
%             
%         end
%         
%     end
    
    methods (Static, Access = public)
       
        function type = getType()
           
            type = eval([mfilename('class') '.Type']);
            
        end
        
    end
    
end