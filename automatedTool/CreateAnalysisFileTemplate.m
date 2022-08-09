function path = CreateAnalysisFileTemplate(filename)
    arguments
        filename = 'AnalysisFileTemplate.json';
    end

    jsonStructure = struct();
    jsonStructure.Protocol = 'Protocol Name';
    jsonStructure.sFile = [];
    
    templatePipeline = CreateTemplatePipeline();
    templatePipeline.preparePipelineToBeSavedToJson();
    jsonStructure.Pipeline = templatePipeline;

    path = fullfile(PathsGetter.getAutomatedToolFolder(), filename);
    FileSaver.save(path, jsonStructure);