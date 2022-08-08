classdef ProcessValidator < Validator
        
    methods (Access = public)
                        
        function verifyIfCtorIsValid(obj, ctorHandle)
            
            if isempty(ctorHandle)
                eID = 'InvalidCtorInput';
                eMsg = 'The input is invalid';
                throw(obj.createException(eID, eMsg));
            end
            
        end
        
        function verifyName(obj, prName)
           
            allProcesses = Process.getAllProcesses();
            types = fieldnames(allProcesses);

            for i = 1:length(types)
                prNames = string(fieldnames(allProcesses.(types{i})));
                if any(strcmpi(prName, prNames))
                    return
                end
            end

            eID = 'InvalidProcessName';
            eMsg = ['The following process name is invalid:' newline ...
            char(prName)];
            throw(obj.createException(eID, eMsg));
           
        end
        
        function verifyParameterStructure(obj, prParameter, parameterToSet)
            
            fields = fieldnames(parameterToSet)';
            
            for i = 1:length(fields)
                parameterValue = parameterToSet.(fields{i});
                expectedCls = class(prParameter.(fields{i}));
                
                if ~isa(parameterValue, expectedCls)
                    eID = 'InvalidParameterClass';
                    eMsg = [ 'Invalid Class.' newline...
                            'The field ''' fields{i} ''' accepts ' expectedCls '.' newline...
                            'The current value''s' ' class is ' class(parameterValue)];
                    throw(obj.createException(eID, eMsg));
                end
                
            end
            
        end

    end
    
end