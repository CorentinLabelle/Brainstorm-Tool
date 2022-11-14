classdef PipelineHistory < History
    
    methods (Access = public)
        
        function obj = PipelineHistory()
            obj = obj@History();
            obj.sHistory.PipelineCopy = {};
        end
        
        function obj = addEntry(obj, pipeline, varargin)
            obj = addEntry@History(obj, varargin);
            row = obj.getNumberOfRow();
            obj.sHistory(row).PipelineCopy = pipeline;            
        end
      
        function previousPipeline = getPreviousPipeline(obj)        
            if obj.isEmpty()
                warning('History is empty, no previous pipeline available.');
                previousPipeline = obj;
            else
                lastEntry = obj.History(obj.getNumberOfRow()-1);
                previousPipeline = lastEntry.PipelineCopy;
            end            
        end        
    end
    
    methods (Static, Access = ?History)
        
        function callerFct = getCallerFunctionName(stack)
            fctCallStack = dbstack;
            callerFct = fctCallStack(6).name;
        end
        
    end

    
end