 classdef PipelinePrinter
    
    methods (Static, Access = ?Pipeline)
        
        function pipelineAsCharacters = convertToCharacters(pipeline)
            
            pipelineAsString = PipelinePrinter.convertToString(pipeline);
            
            % Join string
            pipelineAsCharacters = char(strjoin(pipelineAsString, '\n\n'));
            
        end
        
        function processesAsCharacters = convertProcessToCharacters(pipeline)
            
            % If pipeline is empty
            if isempty(pipeline.Processes)
                processesAsCharacters = 'The pipeline is empty';
                return
            end

            % Join string and convert to characters
            processesAsCharacters = char(strjoin(PipelinePrinter.convertProcessToString(pipeline), '\n'));
            
        end
         
        function processesDocAsCharacters = convertProcessesDocToCharacters(pipeline)
            
            % Build pipeline documentation
            pipDoc = pipeline.Documentation;
            if isempty(pipeline.Documentation)
                pipDoc = 'No Documentation';
            end
            
            prDoc = strjoin(cellfun(@(x) x.convertDocumentationToCharacters, pipeline.Processes, 'UniformOutput', false), '\n');
            
            processesDocAsCharacters = ['PIPELINE' sprintf('\n\t\t') ...
                            pipDoc newline newline prDoc];
                        
        end
       
    end
        
    methods (Static, Access = private)
        
        function processesAsString = convertProcessToString(pipeline)
            
            % Initialize variable
            processesAsString = strings(1, length(pipeline.Processes));

            % Loop through processes
            for i = 1:length(pipeline.Processes)
                processesAsString(i) = [num2str(i), '. ', pipeline.Processes{i}.convertToCharacters];
            end
            
        end
        
        function pipelineAsString = convertToString(pipeline)
            
            % Initialize variable
            pipelineAsString = strings(1, 6);
            
            % Build string
            pipelineAsString(1) = ['PIPELINE', newline, char(pipeline.Name) '[' char(strjoin(pipeline.Extension, '/')) ']'];
            pipelineAsString(2) = ['FOLDER', newline, char(pipeline.Folder)];
            pipelineAsString(3) = ['DATE OF CREATION', newline, char(pipeline.DateOfCreation)];
            pipelineAsString(4) = ['TYPE', newline, char(pipeline.Type)];
            pipelineAsString(5) = ['NUMBER OF PROCESS', newline, num2str(length(pipeline.Processes))];
            pipelineAsString(6) = ['LIST OF PROCESS', newline, PipelinePrinter.convertProcessToCharacters(pipeline)];
                        
        end
        
    end
    
end

