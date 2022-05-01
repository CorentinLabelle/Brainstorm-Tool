function [manager, builder] = startApp(app, pipeline, type)

    addpath('./documentation');
    addpath('./classes');
    addpath('./images');
    addpath('./interface');

    manager = [];
    builder = [];

    if app

        if nargin < 3
            tool = Analysis_Tool();
        else
            tool = Analysis_Tool(type);
        end
        manager = tool.app_Manager;
    end

    if pipeline
        builder = Pipeline_Builder;
    end
    
    %rmpath('./documentation');
    %rmpath('./classes');
    %rmpath('./images');
    %rmpath('./interface');

end