classdef ScalarCreator
    
    methods (Static, Access = {?ProcessFactory, ?CellCreator})
        
        function process = createScalar(ctorHandle, input)
            
            process = ctorHandle(input);
            
        end
        
    end
    
end