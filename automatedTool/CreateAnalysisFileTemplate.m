function path = CreateAnalysisFileTemplate(filename)
    arguments
        filename = 'AnalysisFileTemplate.json';
    end

    jsonStructure = struct();
    jsonStructure.Protocol = 'Protocol Name';
    jsonStructure.sFile = [];
    
    eegPipeline = CreateEegPipeline();
    jsonStructure.Pipeline = eegPipeline.preparePipelineToBeSavedToJson();

    path = fullfile(PathsGetter.getAutomatedToolFolder(), filename);
    FileSaver.save(path, jsonStructure);