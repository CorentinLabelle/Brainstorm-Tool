classdef JsonEncoder
    
    methods (Static, Access = public)
       
        function variableAsJson = encode(variableToEncode)            
            variableAsJson = jsonencode(variableToEncode, 'PrettyPrint', true);            
        end
        
    end
    
end