classdef FileChooser
    
    methods (Abstract)
        
       [file, folder, status] = chooseFile(~, extension, title, path);
        
    end
end

