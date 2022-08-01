classdef DefaultTextInput < TextInput
    
    methods (Access = public)
       
        function text = enterText(~, question, title)
            
            text = inputdlg(question, title, [1 35]);
            %inputdlg('Enter the Subject Name:', 'Subject Name', [1 35]);
            
        end
        
    end
end