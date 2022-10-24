classdef ProcessPrinter
    
    methods (Static, Access = ?Process)
        
        function printAvailableProcesses()
            disp(ProcessPrinter.convertAvailableProcessesToChar());           
        end
        
    end
    
    methods (Static, Access = private)
              
        function availableProcessesAsCharacters = convertAvailableProcessesToChar()            
            availableProcessesAsCharacters = ...
                char(strjoin(ProcessPrinter.convertAvailableProcessesToString, '\n\n') + newline);            
        end
        
        function availableProcessesAsString = convertAvailableProcessesToString()
            database = Database();
            processNamesByClass = database.getProcessNames();
            classes = string(fieldnames(processNamesByClass)');
            
            availableProcessesAsString = strings(1, length(classes));
            for i = 1:length(classes)
                availableProcessesAsString(i) = [...
                    '<strong>' char(classes(i)) ':</strong>' newline ...
                    char(strjoin(processNamesByClass.(classes(i)), '\n'))];                
            end
            
        end         
        
    end
    
end