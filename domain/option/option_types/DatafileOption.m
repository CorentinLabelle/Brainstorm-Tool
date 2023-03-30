classdef DatafileOption < Option
    
    methods (Access = public)
        
        function obj = DatafileOption(varargin)
            obj = obj@Option(varargin{:});
            formats = obj.get_data_formats();
            if length(formats) == 1
                obj.Value(2) = formats;
            end
        end
        
        function obj = set_value(obj, value)
            if ischar(value)
                obj.Value{1} = value;
            elseif iscell(value)
                obj.Value{1} = value{1};
                obj.Value{2} = value{2};
            end
        end
        
        function value = get_value(obj)
           value = obj.Value(1:2);
        end

        function character = to_character(obj)
            character = to_character@Option(obj);
            character = [ ...
                        character newline...
                        sprintf('\t') 'Possible values: ' obj.possible_values_to_character()];
        end
        
    end

    methods (Access = private)

        function character = possible_values_to_character(obj)
            character = char(strjoin(obj.get_data_formats(), ', '));            
        end

        function data_formats = get_data_formats(obj)
            data_formats = obj.Value{1, 8}(:, 3);
        end

    end
    
end

