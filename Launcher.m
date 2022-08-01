classdef Launcher < handle
    
    methods (Static, Access = public)
        
        function startBrainstorm()
            
            if ~PathsGetter.isBrainstorm3FolderInMatlabPath()
                isAdded = PathsAdder.addBrainstorm3Path();
                if ~isAdded
                    return
                end
            end
            
            if ~brainstorm('status')
                brainstorm nogui;
            end
            
        end
            
        function [manager, controller] = launchAnalysisTool()
            
            PathsAdder.addPaths();
            Launcher.startBrainstorm();
            
            tool = Analysis_Tool();
            manager = tool.appManager;
            controller = tool.controller;
            
        end
        
        function [manager, controller] = launchPipelineBuilder()
           
            PathsAdder.addPaths();
            Launcher.startBrainstorm();
            
            pipBuilder = Pipeline_Builder();
            manager = pipBuilder.manager;
            controller = pipBuilder.controller;
            
        end
        
    end
    
end