classdef PipelinePrinterInterface < handle
    
    methods (Abstract, Static, Access = {?Pipeline, ?PipelinePrinter})
        pipelineAsCharacters = convertToCharacters(pipeline);        
        prAsChars = convertProcessToCharacters(pipeline);
    end
    
end