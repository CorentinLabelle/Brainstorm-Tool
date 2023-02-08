classdef DefaultFileChooser < FileChooser
    
    methods (Access = public)
       
        function [file, folder, status] = chooseFile(~, extension, title, path, allowMultiple)
            
            if nargin == 4
                allowMultiple = 'off';
            end
            
            [file, folder, status] = uigetfile(extension, title, path, 'Multiselect', allowMultiple);
            
        end
        
    end
end

