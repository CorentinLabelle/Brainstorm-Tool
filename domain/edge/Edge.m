classdef Edge
    
    properties (GetAccess = public, SetAccess = private)
        Active
    end
    
    methods (Access = public)
        
        function obj = Edge()
            obj.Active = true;
        end
        
        function bool = is_active(obj)
            bool = false(1, length(obj));
            for i = 1:length(bool)
                bool(i) = obj(i).Active;
            end
        end
        
        function obj = activate(obj)
            for i = 1:length(obj)
                edge = obj(i);
                edge.Active = true;
                obj(i) = edge;
            end
        end
        
        function obj = deactivate(obj)
            for i = 1:length(obj)
                edge = obj(i);
                edge.Active = false;
                obj(i) = edge;
            end
        end
        
        %% Json Encoding
        function json = jsonencode(obj, varargin)
            json = string.empty();
        end
        
    end
    
end