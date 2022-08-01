classdef FileReader < handle
        
    methods (Static, Access = public)
        
        function structure = read(filePath)
            
            [~, ~, extension] = fileparts(filePath);
            
            if strcmp(extension, '.json')
                functionAsChar = '.readJson';
            end
            
            functionHandleToReadFile = str2func([mfilename('class'), functionAsChar]);
            structure = functionHandleToReadFile(filePath);
            
        end
        
    end
    
    methods (Static, Access = private)

        function structure = readJson(path)
            
            fileID = fopen(path); 
            raw = fread(fileID, inf);  
            fclose(fileID); 
            
            str = char(raw');
            structure = jsondecode(str);
                    
        end
        
    end
    
end