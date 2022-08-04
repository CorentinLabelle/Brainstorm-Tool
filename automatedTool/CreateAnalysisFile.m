function path = CreateAnalysisFile(filename)
    arguments
        filename = 'AnalysisFile.json';
    end

    jsonStructure = struct();
    jsonStructure.Protocol = 'Protocol Name';
    jsonStructure.sFile = [];
    jsonStructure.Pipeline = CreateEegPipeline();

    path = fullfile(PathsGetter.getAutomatedToolFolder(), 'analysis_files', filename);
    FileSaver.save(path, jsonStructure);