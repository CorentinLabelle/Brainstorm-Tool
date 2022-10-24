classdef PipelineExporter < PipelineExporterInterface
    
    methods (Static, Access = {?Pipeline, ?PipelineExporter})
        
        function export(pipToExport)
            if contains('.mat', pipToExport.getExtension())
                PipelineExporter.save2mat(pipToExport);
            elseif contains('.json', pipToExport.getExtension())
                PipelineExporter.save2json(pipToExport);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function save2mat(PipelineSaved)
            path = fullfile(PipelineSaved.getFolder(), PipelineSaved.getName());
            save(path, "PipelineSaved");
        end
        
        function save2json(pipToExport)
            fileSaver = FileSaver();
            fileSaver.save(pipToExport.getPath('.json'), pipToExport);        
        end
        
        function jsonVar = createJsonVariable(pipeline)
            jsonVar = struct();
            jsonVar.Folder = pipeline.getFolder();
            jsonVar.Name = pipeline.getName();
            jsonVar.Extension = pipeline.getExtension();
            jsonVar.DateOfCreation = pipeline.getDate();
            jsonVar.Documentation = pipeline.getDocumentation();
            jsonVar.ListOfProcesses = pipeline.Processes.getProcess();
        end
        
    end
    
end