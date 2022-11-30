classdef ConstrainedParameterPrinter < ParameterPrinter
    
    methods (Static, Access = {?BstParameter, ?ConstrainedParameterPrinter})
        
        function parameterAsChars = convertToCharacters(parameter)
            parameterAsChars = [...
                char(parameter.getName()) ' ' ...
                ConstrainedParameterPrinter.getOptionnalAsCharacters(parameter.isOptionnal()) ...
                ConstrainedParameterPrinter.getValueClassAsCharacters(parameter.getValueClass()) ...
                ConstrainedParameterPrinter.convertPossibleValueToChar(parameter.getPossibleValue()) ':' ...
                ConstrainedParameterPrinter.convertValueToCharacters(parameter.getValue())];
        end
        
    end
    
    methods (Static, Access = private)
        
        function possibleValueToChar = convertPossibleValueToChar(possibleValue)
            possibleValueAsString = strings(1, length(possibleValue));
            for i = 1:length(possibleValue)
                possibleValueAsString(i) = strcat(num2str(i), '. ', possibleValue{i});
            end
            possibleValueToChar = char(strjoin(string(possibleValueAsString), ' - '));
            possibleValueToChar = [' [possible value: ' possibleValueToChar ']'];
        end
        
    end
    
end