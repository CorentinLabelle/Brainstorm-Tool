classdef Option
    
    properties (GetAccess = public, SetAccess = protected)
        Name
        Value
        Comment
        Type
    end
    
    methods (Access = public)
        
        function obj = Option(name, value, comment, type)
            obj.Name = name;
            obj.Value = value;
            obj.Comment = comment;
            obj.Type = type;
        end
        
        function name = get_name(obj)
            name = obj.Name;
        end
        
        function obj = set_value(obj, value)
            obj.Value = value;
        end
        
        function value = get_value(obj)
            value = obj.Value;
        end
        
        function command = to_command(obj)
            name_command = value_to_command(obj.Name);
            value_command = value_to_command(obj.get_value());
            command = [name_command ', ' value_command];
        end
        
        function character = to_character(obj)
            character = [ ...
                obj.get_name() ': ' Option.comment_to_character(obj.Comment) newline ...
                sprintf('\t') 'Value: ' value_to_command(obj.get_value()) newline ...
                sprintf('\t') 'Type: ' value_to_command(obj.Type)];
        end
        
        function character = to_md_character(obj)
            character = [ ...
                obj.get_name() ': ' Option.comment_to_character(obj.Comment) newline ...
                sprintf('\t\t') '* Value: ' value_to_command(obj.get_value()) newline ...
                sprintf('\t\t') '* Type: ' value_to_command(obj.Type)];
        end
        
    end
    
    methods (Static, Access = protected)
        
        function character = comment_to_character(comment)
            switch class(comment)
                case 'cell'
                    character = char(strjoin(comment, ', '));
                otherwise
                    character = comment;
            end
        end
        
    end
   
end