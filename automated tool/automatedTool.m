function automatedTool(json)
        
    if nargin == 0
        error('You need to enter the path to a pipeline file (.mat or .json)');
    end
    
    paths = [
    "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3", ...
    "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/domaine"
    ];

    % Add paths
    for i = 1:length(paths)
        addpath(genpath(paths(i)));
    end

    % Read json
    fileID = fopen(json); 
    raw = fread(fileID, inf); 
    str = char(raw'); 
    fclose(fileID); 
    structure = jsondecode(str);

    % Get sFiles from json
    if isfield(structure, 'sFiles')
        sFiles = structure.sFiles;
    else
        sFiles = [];
    end

    % Create pipeline from json
    p = Pipeline(structure);

    % Run pipeline
    p.run(sFiles);

    % Remove paths
    for i = 1:length(paths)
        rmpath(genpath(paths(i)));
    end
    
end



