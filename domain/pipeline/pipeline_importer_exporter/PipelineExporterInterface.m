classdef PipelineExporterInterface < handle

    methods (Abstract, Static, Access = {?Pipeline, ?PipelineExporter})
        export(pipToExport);        
    end
    
end