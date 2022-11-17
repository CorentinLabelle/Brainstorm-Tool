classdef Copier
    
    methods (Static, Access = public)

        function Copy(fToCopy, destinationFolder)
            arguments
                fToCopy string
                destinationFolder string
            end
            for i = 1:length(fToCopy)
                folderName = char.empty();
                if isfolder(fToCopy(i))
                    [~, folderName] = fileparts(fToCopy(i));
                end
                [status, msg] = copyfile(fToCopy(i), fullfile(destinationFolder, folderName)); 
                if ~status
                    error(['Error when copying ' fToCopy(i) ': ' msg]);
                end
            end
        end

    end

end