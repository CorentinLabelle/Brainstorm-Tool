classdef PipelineHistory
    
    properties (SetAccess = protected, GetAccess = public)
        sHistory struct = struct();
    end
    
    methods (Access = public)
        
        function obj = PipelineHistory()
            obj = obj.initialize_history();
        end
        
        function obj = add_entry(obj, pipeline, varargin)
            row = obj.get_number_of_row() + 1;
            obj.sHistory(row).Function = obj.get_caller_function_name();
            obj.sHistory(row).Datetime = char(datetime);
            obj.sHistory(row).Parameters = [varargin{:}];
            obj.sHistory(row).PipelineCopy = pipeline;            
        end
        
        function previous_pipeline = get_previous_pipeline(obj)        
            if obj.is_empty()
                warning('History is empty, no previous pipeline available.');
                previous_pipeline = obj;
            else
                last_entry = obj.sHistory(obj.get_number_of_row()-1);
                previous_pipeline = last_entry.PipelineCopy;
            end            
        end
        
        function obj = remove_last_entry(obj, number_of_entry)            
            arguments
                obj History
                number_of_entry int64 = 1;
            end            
            if ~obj.is_empty()
                obj.sHistory(end-number_of_entry+1:end) = [];
            end            
        end
        
    end
    
    methods (Access = private)
        
        function number_of_row = get_number_of_row(obj)
            number_of_row = length(obj.sHistory);
        end
                
        function obj = initialize_history(obj)
            obj.sHistory.Function = 'Creation';
            obj.sHistory.Datetime = char(datetime);
            obj.sHistory.Parameters = {};
            obj.sHistory.PipelineCopy = {};
        end
        
        function bool = is_empty(obj)
            bool = isempty(obj.sHistory);
        end
        
    end  
    
    methods (Static, Access = private)
        
        function callerFct = get_caller_function_name(~)
            fct_call_stack = dbstack;
            callerFct = fct_call_stack(3).name;
        end
        
    end

end