classdef SpecificProcess < Process
    
    methods (Access = ?ProcessClass)
        
        function obj = SpecificProcess()
        end
        
    end
    
    methods (Access = public)
       
        function sFilesOut = run(obj, sFilesIn)
            sensorType = SFileManager.getSensorTypeFromsFile(sFilesIn);
            analyzer = sensorType.getAnalyzer();
            analyzerFunction = obj.getAnalyzerFct();
            sFilesOut = analyzerFunction(analyzer, obj.getParameter(), sFilesIn);
        end
        
    end
    
end