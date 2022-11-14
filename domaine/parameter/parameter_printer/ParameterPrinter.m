classdef ParameterPrinter
    
    methods (Static, Access = {?BstParameter, ?ConstrainedParameterPrinter})
        
        function parameterAsChars = convertToCharacters(parameter)
            parameterAsChars = [...
                char(parameter.getName()) ' ' ...
                ParameterPrinter.getOptionnalAsCharacters(parameter.isOptionnal()) ...
                ParameterPrinter.getValueClassAsCharacters(parameter.getValueClass()) ...
                ParameterPrinter.getDefaultValueAsCharacters(parameter.getDefaultValue()) ': ' ...
                ParameterPrinter.convertValueToCharacters(parameter.getValue())];
        end
        
    end
    
    methods (Static, Access = protected)
        
        function optionnalAsChars = getOptionnalAsCharacters(isOptionnal)
            if isOptionnal
                optionnalAsChars = '[optionnal]';
            else
                optionnalAsChars = '[required]';
            end
        end        
                
        function valueClassAsChar = getValueClassAsCharacters(valueClass)
            valueClassAsChar = ['[class: ' char(valueClass) ']'];
        end
        
        function defaultValueAsChar = getDefaultValueAsCharacters(defaultvalue)
            defaultValueAsChar = char.empty();
            if ~isempty(defaultvalue)
                defaultValueAsChar = ['[default: ' ...
                    ParameterPrinter.convertValueToCharacters(defaultvalue) ']'];
            end
        end
        
        function parameterValueAsChar = convertValueToCharacters(value)
            if ischar(value)
                parameterValueAsChar = value;
            elseif iscell(value)
                parameterValueAsChar = [ParameterPrinter.convertCellToCharacter(value) ' | '];
            elseif isstruct(value)
                parameterValueAsChar = ParameterPrinter.convertStructToCharacter(value);
            else
                parameterValueAsChar = mat2str(value);
            end            
        end
        
        function cellAsChars = convertCellToCharacter(value)
            fctHandle = @ParameterPrinter.convertValueToCharacters;
            cellAsChars = cellfun(@(x) fctHandle(x), value, 'UniformOutput', false);
            cellAsChars = char(strjoin(cellAsChars, ', '));
        end
          
        function structAsChars = convertStructToCharacter(value)
            fields = string(fieldnames(value)');
            values = strings(1, length(fields));
            for i = 1:length(fields)
                values(i) = string(value.(fields(i)));
            end
            structAsChars = char(strjoin(fields + ': ' + values, ', '));
        end
        
    end
    
end