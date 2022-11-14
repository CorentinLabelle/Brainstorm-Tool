classdef ProcessDetails < Details
    
    properties (SetAccess = private, GetAccess = public)
        AnalyzerFct;
        fName char;
        sProcess struct;
    end
    
    methods (Access = ?Process)
        
        function obj = setfName(obj, fName)
            obj.fName = fName;
            obj = obj.setSProcess();
        end
        
        function obj = setAnalyzerFct(obj, analyzerFct)
            obj.AnalyzerFct = analyzerFct;
        end
        
        function fName = getfName(obj)
            fName = obj.fName;
        end
        
        function analyzerFct = getAnalyzerFct(obj)
            analyzerFct = obj.AnalyzerFct;
        end
        
        function sProcess = getSProcess(obj)
            sProcess = obj.sProcess;
        end
        
    end
    
    methods (Access = private)
        
        function obj = setSProcess(obj)
            obj.sProcess = panel_process_select('GetProcess', obj.fName);
        end
        
    end
    
end