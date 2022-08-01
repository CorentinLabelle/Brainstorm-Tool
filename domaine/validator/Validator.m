classdef Validator < handle
        
    methods (Access = protected)
        
        function me = createException(obj, id, msg, cause)
            
            arguments
                obj Validator
                id char
                msg char
                cause char = char.empty;
            end
            
            exceptionID = [class(obj) ':' id];
            me = MException(exceptionID, msg);
            
            if ~isempty(cause)
                causeException = MException(exceptionID, cause);
                me.addCause(causeException);
            end
            
        end
        
    end
    
    methods (Static, Access = public)
        
        function validStruct = removeAndWarnForInvalidFieldInStruct(fieldCell, structToModify)
            
            fieldsToSet = fieldnames(structToModify)';
            validFields = intersect(fieldCell, fieldsToSet);
            invalidFields = setxor(fieldsToSet, validFields);
              
            if ~isempty(invalidFields)                
                warning(['The following fieldnames have not been considered:'...
                newline strjoin(invalidFields, '\n') ...
                newline newline 'Here is the list of valid fields:' ...
                newline char(strjoin(fieldCell, '\n'))]);
            end
            
            validStruct = rmfield(structToModify, invalidFields);
            
        end
        
    end
    
    
end

