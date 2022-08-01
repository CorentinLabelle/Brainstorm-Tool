classdef ProcessConverter
    
    methods (Static, Access = ?Process)
        
        function castedProcess = cast(processToCast, finalCls)
            
            m = size(processToCast, 1);
            n = size(processToCast, 2);
            castedProcess = cell(m,n);
            
            for i = 1:m
                for j = 1:n
                    if ~ProcessConverter.isCastingNecessary(processToCast(i,j), finalCls)
                        castedProcess = processToCast(i,j);
                        return
                    end
                    ProcessConverter.verifyCastingIsValid(processToCast(i,j), finalCls);
                    constructorHandle = str2func(finalCls);
                    castedProcess{i,j} = constructorHandle();
                    castedProcess{i,j} = ProcessFactory.fillEmptyProcessWithProcess(castedProcess{i,j}, processToCast(i,j));
                end
            end
            
            castedProcess = ProcessFactory.convertCellToMat(castedProcess);

        end
        
    end
       
    methods (Static, Access = private)
            
        function verifyCastingIsValid(process, finalCls)
            
            errorMsg = [ 'Casting from ' char(class(process)) ...
                    ' to ' char(finalCls) ' is impossible.'];
            exceptionID = [mfilename('class') ':' 'InvalidCasting'];
            me = MException(exceptionID, errorMsg);            
          
            switch class(process)
                case 'EEG_Process'
                    if strcmpi(finalCls, 'MEG_Process')
                        throw(me);
                    end                   
                case 'MEG_Process'
                    if strcmpi(finalCls, 'EEG_Process')
                        throw(me);
                    end  
            end
            
        end
           
        function isNecessary = isCastingNecessary(process, finalCls)
        
            isNecessary = true;
            if strcmpi(class(process), finalCls)
                isNecessary = false;
            end
            
        end        
        
    end
    
end