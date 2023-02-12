classdef FileReader < handle
        
    methods (Static, Access = public)
        
        function structure = read(filePath)
            
            assert(isfile(filePath), ['The following path does not exist:' newline filePath]);
            
            [~, ~, extension] = fileparts(filePath);
            
            if strcmpi(extension, '.json')
                functionAsChar = '.readJson';
            elseif strcmpi(extension, '.mat')
                functionAsChar = '.readMat';
            else
                error(['The file format ' extension ' is not supported!']);
            end
            
            functionHandleToReadFile = str2func([mfilename('class'), functionAsChar]);
            structure = functionHandleToReadFile(filePath);
            
        end
        
    end
    
    methods (Static, Access = private)

        function structure = readJson(path)            
            structure = JsonDecoder.decode(path);                    
        end
        
        function structure = readMat(path)
            structure = load(path);            
        end
        
    end
    
end