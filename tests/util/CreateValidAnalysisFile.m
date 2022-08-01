function path = CreateValidAnalysisFile()

    jsonStructure = struct();
    jsonStructure.Protocol = 'New Protocol';
    jsonStructure.sFile = [];
    jsonStructure.Pipeline = EegPipeline();
    
    path = [mfilename('fullpath') '.json'];
    FileSaver.save(path, jsonStructure);