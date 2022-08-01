classdef PipelineExporter < handle
    
    methods (Access = ?Pipeline)
        
        function export(obj, pipToExport)
            
            if contains('.mat', pipToExport.Extension)
                obj.save2mat(pipToExport);
            end
            
            if contains('.json', pipToExport.Extension)
                obj.save2json(pipToExport);
            end
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function save2mat(pipToExport)
        % Saves pipeline to .mat file.
        %
        % USAGE
        %       obj.save2mat()
            
            pipelineAsStructure = PipelineExporter.convertPipelineToStructure(pipToExport);
            path = fullfile(pipToExport.Folder, pipToExport.Name);
            save(path, "-struct", "pipelineAsStructure");
            
        end
        
        function save2json(pipToExport)
        % Saves pipeline to .json file.
        %
        % USAGE
        %       obj.save2json()
        
            % Deep Copy
            pipCopy = copy(pipToExport);
            
            pipCopy.preparePipelineToBeSavedToJson();
            path = fullfile(pipCopy.Folder, strcat(pipCopy.Name, '.json'));
            
            fileSaver = FileSaver();
            fileSaver.save(path, pipCopy);
        
        end
             
        function pipelineAsStructure = convertPipelineToStructure(pipToConvert)
        % Converts the pipeline to a structure.
        % This method is used before saving the pipeline to a .mat file.
        %
        % OUTPUT
        %       structure [struct]
        %
        % USAGE
        %       S = obj.convertPipelineToStructure()
            
            pipelineAsStructure = struct();
            prop = properties(pipToConvert);
            
            for i = 1:length(prop)
                pipelineAsStructure.(prop{i}) = pipToConvert.(prop{i});
            end
            
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
