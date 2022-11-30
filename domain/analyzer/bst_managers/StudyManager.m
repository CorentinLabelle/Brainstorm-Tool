classdef StudyManager
    
    methods (Static, Access = public)
        
        function deleteStudy(sFiles)            
            bst_process('CallProcess', 'process_delete', sFiles, [], ...
            'target', 2); % 1: fichier 2: folder (recommended) 3: subjects
        end
        
    end
    
end