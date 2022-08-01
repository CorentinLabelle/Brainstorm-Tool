classdef PipelineModifierForJson < handle
    
    properties (Access = private)
        
        PipelineToModify;
        
    end
    
    methods (Access = ?Process)
        
        function obj = ProcessModifierForJson(pipelineToModify)
            
            obj.PipelineToModify = pipelineToModify;
            
        end
        
        function deletePipelinesFromHistory(obj)
        % Deletes pipelines objects from history.
        % This method is used when saving to a .json file.
        %
        % USAGE
        %       obj.deletePipelinesFromHistory()
            
            % Delete Pipelines
            for i = 1:length(obj.PipelineToModify.History)
                obj.PipelineToModify.History(i).PipelineCopy = [];
            end
            
        end
                
        function deleteSProcessFromHistory(obj)
                       
            for i = 1:length(obj.History)
                parameter = obj.History(i).Parameters;
                if isa(parameter, 'Process')
                    parameter.deleteSProcess;
                end
            end
            
        end
                        
        function preparePipelineToBeSavedToJson(obj)
           
            obj.deletePipelinesFromHistory;
            %obj.deleteSProcessFromHistory;
            
        end
        
        function processModified = modify(obj)
            
        end
        
    end
end

