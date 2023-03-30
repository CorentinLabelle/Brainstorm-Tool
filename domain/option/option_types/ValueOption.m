classdef ValueOption < Option
    
    methods (Access = public)
        
        function obj = ValueOption(varargin)
            obj = obj@Option(varargin{:});         
        end
        
        function obj = set_value(obj, value)
            obj.Value{1} = value;
        end
        
        function value = get_value(obj)
            value = [];
            if ~isempty(obj.Value)
                value = obj.Value{1};
            end
        end
        
    end
end