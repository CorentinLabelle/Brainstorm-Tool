 classdef PipelinePrinter < PipelinePrinterInterface
    
    methods (Static, Access = {?Pipeline, ?PipelinePrinter})
        
        function pipelineAsCharacters = convertToCharacters(pipeline)
            pipelineAsString = PipelinePrinter.convertToString(pipeline);
            pipelineAsCharacters = char(strjoin(pipelineAsString, '\n\n'));            
        end
        
        function prAsChars = convertProcessToCharacters(pipeline)
            prAsChars = pipeline.Processes.convertToCharacters();
        end
        
    end
        
    methods (Static, Access = private)
        
        function processesAsString = convertProcessToString(pipeline)
            processesAsString = strings(1, pipeline.Processes.getNumberOfProcess());
            for i = 1:length(processesAsString)
                processesAsString(i) = [num2str(i), '. ', pipeline.getProcess(i).convertToCharacters()];
            end            
        end
        
        function pipAsString = convertToString(pipeline)
            pipAsString = strings(1, 7);
            pipAsString(1) = ['PIPELINE', newline, char(pipeline.getName())];
            pipAsString(2) = ['FOLDER', newline, char(pipeline.getFolder())];
            pipAsString(3) = ['EXTENSION', newline, char(pipeline.getExtension())];
            pipAsString(4) = ['DATE OF CREATION', newline, char(pipeline.getDate())];
            pipAsString(5) = ['TYPE', newline, char(pipeline.getType())];
            pipAsString(6) = ['NUMBER OF PROCESS', newline, num2str(pipeline.getNumberOfProcess())];
            pipAsString(7) = ['LIST OF PROCESS', newline, PipelinePrinter.convertProcessToCharacters(pipeline)];       
        end
        
    end
    
 end