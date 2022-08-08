function path = CreateAnalysisFileTemplate(filename)
    arguments
        filename = 'AnalysisFileTemplate.json';
    end

    jsonStructure = struct();
    jsonStructure.Protocol = 'Protocol Name';
    jsonStructure.sFile = [];
    
    eegPipeline = CreateEegPipeline();
    eegPipeline.preparePipelineToBeSavedToJson();
    jsonStructure.Pipeline = JsonEncoder.encode(eegPipeline);

    path = fullfile(PathsGetter.getAutomatedToolFolder(), filename);
    FileSaver.save(path, jsonStructure);