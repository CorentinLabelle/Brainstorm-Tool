classdef ProcessParameterSetter
    
    methods (Static, Access = ?Process)
        
        function obj = ProcessParameterSetter()
        end
        
        function prParameter = setParameter(prParameter, parameterToSet)
            arguments
                prParameter (1,1) struct
                parameterToSet (1,1) struct
            end
            
            parameterToSet = ProcessParameterSetter.formatParameterNames(parameterToSet);
            
            parameterToSet = ProcessParameterSetter.removeAndWarnForInvalidFieldInStruct(...
                                prParameter, ...
                                parameterToSet);
            
            validator = ProcessValidator();
            validator.verifyParameterStructure(prParameter, parameterToSet)
                            
            fields = fieldnames(parameterToSet);
            for i = 1:length(fields)
                prParameter.(fields{i}) = parameterToSet.(fields{i});
            end
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function parameterToSet = removeAndWarnForInvalidFieldInStruct(prParameter, parameterToSet)
        
            validFields = intersect(fieldnames(prParameter), fieldnames(parameterToSet));
            invalidFields = setxor(validFields, fieldnames(parameterToSet));
            
            if ~isempty(invalidFields)
                warning(['The following fields are invalids:' newline ...
                        char(strjoin(string(invalidFields), '\n')) newline ...
                        'Here is the list of valid fields: ' newline ...
                        char(strjoin(string(fieldnames(prParameter)), '\n'))]);
            end
            
            parameterToSet = rmfield(parameterToSet, invalidFields);
            
        end
        
        function newParameterToSet = formatParameterNames(oldParameterToSet)
            
            oldFields = string(fieldnames(oldParameterToSet)');
            
            for i = 1:length(oldFields)
                newField = Process.formatParameterName(oldFields(i));
                newParameterToSet.(newField) = oldParameterToSet.(oldFields(i));
            end
            
        end
        
    end
    
end