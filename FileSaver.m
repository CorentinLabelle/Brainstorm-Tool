classdef FileSaver < handle
    
    methods (Static, Access = public)
        
        function save(filePath, variableToSave)
            
            [~, ~, extension] = fileparts(filePath);
            
            if strcmpi(extension, '.tsv')
                functionAsChar = '.saveToTsv';
            elseif strcmp(extension, '.json')
                functionAsChar = '.saveToJson';
            end
            
            functionHandleToSaveFile = str2func([mfilename('class'), functionAsChar]);
            functionHandleToSaveFile(filePath, variableToSave); 
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function path = saveToTsv(path, variableToSave)
           
            [folder, fileName] = fileparts(path);
            
            % Change extension to .txt temporarily, before saving
            txtPath = fullfile(folder, strcat(fileName, '.txt'));
            
            % Write file to .txt file
            writematrix(variableToSave, txtPath, 'Delimiter', 'tab');
            
            % Change extension (.txt to .tsv)
            movefile(txtPath, path);
            
        end

        function path = saveToJson(path, variableToSave)
           
            fileID = fopen(path, 'wt');
            fprintf(fileID, jsonencode(variableToSave, 'PrettyPrint', true));
            fclose(fileID);
            
        end
        
    end
    
end