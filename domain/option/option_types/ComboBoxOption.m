classdef ComboBoxOption < Option
    
    methods (Access = public)
        
        function obj = ComboBoxOption(varargin)
            obj = obj@Option(varargin{:});
        end
        
        function obj = set_value(obj, value)
            possible_values = obj.Value{2};
            if ischar(value)
                index = find(cellfun(@(x) strcmp(x, value), possible_values));
                obj.Value{1} = index;
            elseif isnumeric(value)
                obj.Value{1} = value;
            end
        end
        
        function value = get_value(obj)
            value = obj.Value{1};
        end
        
    end
    
end

