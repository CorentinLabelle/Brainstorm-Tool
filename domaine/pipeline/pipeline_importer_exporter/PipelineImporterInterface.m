classdef PipelineImporterInterface < handle

    methods (Abstract, Static, Access = {?Pipeline, ?PipelineImporter})
        export(pipToExport);        
    end
    
end