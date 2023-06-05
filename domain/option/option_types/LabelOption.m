classdef LabelOption < Option
    
    methods (Access = public)
        
        function obj = LabelOption(varargin)
            obj = obj@Option(varargin{:});
        end
        
        function character = to_character(obj)
            character = [ ...
                obj.get_name() ': ' obj.Type ' - Not an option.'];
        end
        
        function character = to_md_character(~)
            character = char.empty();
        end
        
    end    
end