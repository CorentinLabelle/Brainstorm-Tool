classdef ProcessPrinter
    
    methods (Static, Access = ?Process)
        
        function processAsString = convertToString(processes)
            
            m = size(processes, 1);
            n = size(processes, 2);
           
            processAsString = strings(m,n);
            for i = 1:m
                for j = 1:n
                    pr = processes(i,j);
                    processAsString(i,j) = [
                        char(pr.Name) ' [' char(pr.getType()) ']' ...
                        sprintf('\n\t\t') ...
                        char(strjoin(ProcessPrinter.convertParametersToString(pr), '\n\t\t'))];
                end
            end
            
        end
        
        function parametersAsStrings = convertParametersToString(process)
            % Format the parameters to characters.
            % param[out]: Parameters formated [char]            
            
            fields = fieldnames(process.Parameters);
            
            if isempty(fields)
                parametersAsStrings = strings(1,1);
                parametersAsStrings(1) =  'No Parameters';
                return
            end
            
            parametersAsStrings = strings(1, length(fields));
            for i = 1:length(fields)
                param = process.Parameters.(fields{i});
                paramClassChar = ['[' class(param) ']'];
                paramChar = ProcessPrinter.convertParameterValueToChar(param);
                
                parametersAsStrings(i) = [fields{i} ' ' paramClassChar ' ' paramChar];    
            end
                        
        end
        
        function docAsString = convertDocumentationToString(processes)
           
            m = size(processes, 1);
            n = size(processes, 2);

            docAsString = strings(m,n);
            for i = 1:m
                for j = 1:n
                  doc = processes(i,j).Documentation;                    
                  docAsString(i,j) = ...
                      [char(processes(i,j).Name) sprintf('\n\t\t') doc];
                end       
            end
            
        end
        
        function printAvailableProcesses()
           
            disp(ProcessPrinter.convertAvailableProcessesToChar());
            
        end
        
    end
    
    methods (Static, Access = private)
              
        function availableProcessesAsCharacters = convertAvailableProcessesToChar()
            
            availableProcessesAsCharacters = ...
                char(strjoin(ProcessPrinter.convertAvailableProcessesToString, '\n\n'));
            
        end
        
        function availableProcessesAsString = convertAvailableProcessesToString()
            
            allProcesses = Process.getAllProcesses();
            availableTypes = string(fieldnames(allProcesses));
            nbType = length(availableTypes);
            
            availableProcessesAsString = strings(1, nbType);
            for i = 1:nbType
                type = availableTypes(i);
                availableProcessesAsString(i) = [...
                    '<strong>' char(upper(type)) ' PROCESSES:</strong>' newline ...
                    char(strjoin(fieldnames(allProcesses.(type)), '\n'))];
                
            end
            
        end
         
        function parameterValueAsChar = convertParameterValueToChar(value)
            
            parameterValueAsChar = char.empty;
            if ~isempty(value) || ischar(value)
                
                if isstring(value)
                    parameterValueAsChar = convertStringsToChars(strjoin(value, ', '));

                elseif islogical(value)
                    parameterValueAsChar = 'No';
                    if (value)
                        parameterValueAsChar = 'Yes';
                    end

                elseif iscell(value)
                    parameterValueAsChar = ProcessPrinter.printCellContent(value);

                else
                    parameterValueAsChar = num2str(value);
                end
            end
            
        end
          
        function cellContenteAsCharacters = printCellContent(c)
            
            if isa(c{1}, 'char')

                str = strings(1,length(c));

                for j = 1:length(str)
                    str(j) = c{j};
                end
                cellContenteAsCharacters = char(strjoin(str, ', '));
                
            else 
                cellContenteAsCharacters = num2str(cellfun('length', c));
                
            end
            
        end

    end
    
end

