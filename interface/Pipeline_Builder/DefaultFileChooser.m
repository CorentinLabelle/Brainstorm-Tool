classdef DefaultFileChooser < FileChooser
    
    methods (Access = public)
       
        function [file, folder, status] = chooseFile(~, extension, title, path, allowMultiple)
            
            if nargin == 3
                allowMultiple = 'off';
            end
            
            [file, folder, status] = uigetfile(extension, title, path, 'Multiselect', allowMultiple);
            
        end
        
    end
end

