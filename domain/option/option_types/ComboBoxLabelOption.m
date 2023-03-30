classdef ComboBoxLabelOption < Option
    
    methods (Access = public)
        
        function obj = ComboBoxLabelOption(varargin)
            obj = obj@Option(varargin{:});
        end
        
        function obj = set_value(obj, value)
            if ischar(value)
                obj.Value{1} = value;
            elseif isnumeric(value)
                obj.Value{1} = obj.Value{2}(1, value);
            end
        end
        
        function value = get_value(obj)
            value = obj.Value{1};
        end
        
    end
    
end

