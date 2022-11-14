classdef History
    
    properties (SetAccess = protected, GetAccess = public)
        sHistory struct = struct();
    end
    
    methods (Access = public)
        
        function obj = History()
            obj = obj.initializeHistory(); 
        end
        
        function NumberOfRow = getNumberOfRow(obj)
            NumberOfRow = length(obj.sHistory);
        end
        
        function isEmpty = isEmpty(obj)
            isEmpty = isempty(obj.sHistory);
        end
        
        function obj = removeLastEntry(obj, numberOfEntry)            
            arguments
                obj History
                numberOfEntry int64 = 1;
            end            
            if ~obj.isEmpty()
                obj.sHistory(end-numberOfEntry+1:end) = [];
            end            
        end
        
        function obj = addEntry(obj, varargin)
            row = obj.getNumberOfRow() + 1;
            obj.sHistory(row).Function = obj.getCallerFunctionName();
            obj.sHistory(row).Datetime = char(datetime);
            obj.sHistory(row).Parameters = [varargin{:}];
        end
        
    end
    
    methods (Access = private)
        
        function obj = initializeHistory(obj)
            obj.sHistory.Function = 'Creation';
            obj.sHistory.Datetime = char(datetime);
            obj.sHistory.Parameters = {};
        end
        
    end    
    
end