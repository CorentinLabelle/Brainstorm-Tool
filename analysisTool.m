function [toolController, pipBuilderController] = analysisTool(tool, pipBuilder)
     
    % Path to tool and controller
    paths = "C:/Users/alab/Desktop/Corentin/AnalysisTool/interface";
    
    for i = 1:length(paths)
        addpath(genpath(paths(i)));
    end
    
    toolController = Controller.empty();
    pipBuilderController = Controller.empty();
    
    if nargin == 0
        tool = 1;
        pipBuilder = 0;
    end
    
    if tool
        
        tool = Analysis_Tool;
        toolController = tool.controller;
        
    end

    if pipBuilder
        
        pipBuilder = Pipeline_Builder;
        pipBuilderController = pipBuilder.controller;
        
    end

end