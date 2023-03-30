classdef RadioLineOption < Option
    
    methods (Access = public)
        
        function obj = RadioLineOption(varargin)
            obj = obj@Option(varargin{:});
        end
        
        function obj = set_value(obj, value)
            possible_values = obj.Comment;
            if ischar(value)
                index = find(cellfun(@(x) strcmp(x, value), possible_values));
                obj.Value = index;
            elseif isnumeric(value)
                obj.Value = value;
            end
        end
        
        function value = get_value(obj)
            value = obj.Value;
        end
        
    end
    
end

