classdef ConstrainedParameter < BstParameter
    
    properties (SetAccess = private, GetAccess = public)
        PossibleValue cell = {};
    end
    
    methods (Access = ?ParameterFactory)
        
        function obj = ConstrainedParameter(name, valueClass, defaultValue, possibleValue)
            obj = obj@BstParameter(name, valueClass, defaultValue);
            obj.PossibleValue = possibleValue;
        end
        
    end
    
    methods (Access = public)
        
        function obj = setValue(obj, indexOrValue)
            if isempty(indexOrValue)
                obj = obj.setToDefault();
            elseif isnumeric(indexOrValue)
                obj = obj.setValueWithIndex(indexOrValue);
            else
                obj = obj.setValueWithPossibleValue(indexOrValue);
            end
        end
        
        function parameterAsChars = convertToCharacters(obj)
            parameterAsChars = ConstrainedParameterPrinter.convertToCharacters(obj);
        end
        
    end
    
    methods (Access = private)
        
        function obj = setValueWithIndex(obj, index)
            obj.verifyIndexIsValid(index);
            value = obj.PossibleValue{index};
            obj.Value = value;
        end
        
        function obj = setValueWithPossibleValue(obj, value)
            obj.verifyValueIsInPossibleValue(value);
            obj.Value = value;
        end
                
        function verifyIndexIsValid(obj, index)
            maxIndex = length(obj.PossibleValue);
            if index <= 0 || index > maxIndex
                error(  ['The index of this parameter should be between ' ...
                         '1 and ' num2str(maxIndex) ' (actual: ' num2str(index) ').']);
            end
        end
        
        function verifyValueIsInPossibleValue(obj, value)
            indexOfValue = find(cellfun(@(x) isequal(x, value), obj.PossibleValue), 1);
            if isempty(indexOfValue)
               error(['The value your are assignin is invalid' newline ...
                    'Possible values: ' obj.convertPossibleValueToChar() newline ...
                    'Actual value: ' value]);
            end
        end
        
    end
    
    methods (Access = ?ConstrainedParameterPrinter)
       
        function possibleValue = getPossibleValue(obj)
            possibleValue = obj.PossibleValue;
        end
        
    end       
    
end