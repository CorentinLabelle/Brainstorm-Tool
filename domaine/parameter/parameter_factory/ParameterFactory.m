classdef ParameterFactory
    
    methods (Static, Access = public)
       
        function parameter = create(name, valueClass, defaultValue, possibleValue)
            if nargin == 3
                parameter = BstParameter(name, valueClass, defaultValue);
            elseif nargin == 4
                parameter = ConstrainedParameter(name, valueClass, defaultValue, possibleValue);
            end
        end
        
    end
    
end