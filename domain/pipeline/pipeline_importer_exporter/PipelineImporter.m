classdef PipelineImporter < PipelineImporterInterface
    
    methods (Static, Access = {?Pipeline, ?PipelineImporter})
        
        function pipeline = importFile(filePath)
            [~, ~, extension] = fileparts(filePath);
            if strcmp(extension, '.json')
                pipeline = PipelineImporter.importJson(filePath);
            elseif strcmp(extension, '.mat')
                pipeline = PipelineImporter.importMat(filePath);
            else
                error(['Invalid extension (' char(extension) ').']);
            end
        end
        
    end
    
    methods (Static, Access = private)
       
        function pipeline = importMat(filePath)
            matStruct = FileReader.read(filePath);
            fields = fieldnames(matStruct);
            assert(length(fields) == 1);
            pipeline = matStruct.(fields{1});
        end
        
        function pipeline = importJson(filePath)
            jsonVar = FileReader.read(filePath);
            pipeline = Pipeline();
            pipeline = pipeline.setName(jsonVar.Name);
            pipeline = pipeline.setFolder(jsonVar.Folder);
            pipeline = pipeline.setExtension(jsonVar.Extension);
            pipeline = pipeline.setDate(jsonVar.Date);
            %pipeline = pipeline.setDocumentation(jsonVar.Documentation);
            pipeline = pipeline.addProcess(Process.create(jsonVar.Processes));
        end
        
    end
    
end