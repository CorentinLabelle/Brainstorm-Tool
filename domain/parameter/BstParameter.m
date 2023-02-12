classdef BstParameter
    
    properties (SetAccess = protected, GetAccess = public)
        Name (1,1) string;
        Value;
        ValueClass char;
        DefaultValue;
        IsOptionnal (1,1) logical = false;
    end
    
    properties (Access = protected)
        ConverterFunction function_handle
        ValidityFunction function_handle
        PreAssigningConverterFunction function_handle
    end
    
    methods (Access = {?ParameterFactory, ?ConstrainedParameter})
                
        function obj = BstParameter(name, valueClass, defaultValue)
            obj.Name = name;
            obj.Value = defaultValue;
            obj.ValueClass = valueClass;
            obj.DefaultValue = defaultValue;
        end
        
    end
    
    methods (Access = public)      
        
        function name = getName(obj)
            name = obj.Name;
        end
        
        function obj = setOptionnal(obj)
            obj.IsOptionnal = true;
        end
        
        function obj = setValue(obj, value)
            if isempty(value)
                obj.setToDefault();
            else
                %value = obj.castValue(value);
                value = obj.preAssigningConversion(value);
                obj.verifyClassOfValueIsValid(value);
                obj.verifyValueIsValid(value)
                obj.Value = value;
            end
        end
        
        function value = getConvertedValue(obj)
            value = obj.Value;
            converter = obj.ConverterFunction;
            if ~isempty(converter)
                value = converter(value);
            end
        end        
        
        function value = getValue(obj)
            value = obj.Value;
        end
        
        function obj = setConverterFunction(obj, fctHandle)
            obj.ConverterFunction = fctHandle;
        end
        
        function obj = setValidityFunction(obj, fctHandle)
            obj.ValidityFunction = fctHandle;
        end
        
        function obj = setPreAssigningConvertFunction(obj, fctHandle)
           obj.PreAssigningConverterFunction = fctHandle;
        end
        
        function isEqual = eq(obj, parameter)
            isEqual = ...
                strmcmpi(obj.getName(), parameter.getName()) && ...
                isequal(obj.getValue(), parameter.getValue());
        end
        
        function paramAsCell = cell(obj)
            paramAsCell = cell(size(obj));
            for i = 1:length(obj)
                paramAsCell(i) = {obj(i)};
            end
        end
        
        function disp(obj)
            disp(obj.convertToCharacters());
        end
        
        function parameterAsChars = convertToCharacters(obj)
            parameterAsChars = ParameterPrinter.convertToCharacters(obj);
        end
        
    end
    
    methods (Access = protected)
        
        function obj = setToDefault(obj)
            obj.Value = obj.DefaultValue;
        end
        
        function value = castValue(obj, value)
            try
                value = cast(value, obj.ValueClass);
            catch 
               error([ 'Invalid class.' newline ...
                        'Field: ' char(obj.getName()) newline ...
                        'Expected class: ' char(obj.ValueClass) newline ...
                        'Actual class: ' char(class(value))]);
            end
        end
        
        function verifyClassOfValueIsValid(obj, value)
            if ~isa(value, obj.ValueClass)
                error([ 'Invalid class.' newline ...
                        'Field: ' char(obj.getName()) newline ...
                        'Expected class: ' char(obj.ValueClass) newline ...
                        'Actual class: ' char(class(value))]);
            end
        end
        
        function verifyValueIsValid(obj, value)
            validator = obj.ValidityFunction;
            if ~isempty(validator)
                validator(value);
            end
        end
        
        function value = preAssigningConversion(obj, value)
            converter = obj.PreAssigningConverterFunction;
            if ~isempty(converter)
                value = converter(value);
            end
        end
        
    end
    
    methods (Access = ?ParameterPrinter)
        
        function isOptionnal = isOptionnal(obj)
            isOptionnal = obj.IsOptionnal;
        end
        
        function valueClass = getValueClass(obj)
            valueClass = obj.ValueClass;
        end
        
        function defaultValue = getDefaultValue(obj)
            defaultValue = obj.DefaultValue;
        end
                
    end
    
end