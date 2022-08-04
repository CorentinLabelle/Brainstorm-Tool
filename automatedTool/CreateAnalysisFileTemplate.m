function path = CreateAnalysisFileTemplate(filename)
    arguments
        filename = 'AnalysisFileTemplate.json';
    end

    jsonStructure = struct();
    jsonStructure.Protocol = 'Protocol Name';
    jsonStructure.sFile = [];
    jsonStructure.Pipeline = CreateEegPipeline();

    path = fullfile(PathsGetter.getAutomatedToolFolder(), filename);
    FileSaver.save(path, jsonStructure);