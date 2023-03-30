classdef SeparatorOption < LabelOption
    
    methods (Access = public)
        
        function obj = SeparatorOption(varargin)
            obj = obj@LabelOption(varargin{:});
        end
        
    end
end

