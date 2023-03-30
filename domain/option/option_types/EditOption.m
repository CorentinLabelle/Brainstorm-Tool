classdef EditOption < Option
    
    methods (Access = public)
        
        function obj = EditOption(varargin)
            obj = obj@Option(varargin{:});
        end
        
        function obj = set_value(obj, structure)
            obj.Value = structure;
        end
        
        function value = get_value(obj)
            value = obj.Value;
        end
        
    end
    
end


