classdef JsonDecoder
    
    methods (Static, Access = public)
       
        function structure = decode(jsonPath)
            fileID = fopen(jsonPath); 
            raw = fread(fileID, inf);  
            fclose(fileID);            
            str = char(raw');
            structure = jsondecode(str);
            structure = JsonDecoder.convertColumnFieldsToRow(structure);
        end
        
    end
    
    methods (Static, Access = private)
        
        function structure = convertColumnFieldsToRow(structure)
            for i = 1:length(structure)
                fields = fieldnames(structure(i));
                for j = 1:length(fields)
                    value = structure(i).(fields{j});
                    if isstruct(value)
                        value = JsonDecoder.convertColumnFieldsToRow(value);
                    elseif iscolumn(value)
                        value = value';
                    end
                    structure(i).(fields{j}) = value;
                end
            end
        end
        
    end
    
end