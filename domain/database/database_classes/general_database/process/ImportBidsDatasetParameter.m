function parameters = ImportBidsDatasetParameter()
    p1 = ParameterFactory.create('folder', 'char', char.empty());
    p1 = p1.setPreAssigningConvertFunction(@convertRelativePathToAbsolute);
    p1 = p1.setValidityFunction(@isFolderValid);
    parameters = {p1};
end
    
function isFolderValid(folder)
    if ~isfolder(folder)
       error(['The following folder does not exists: ' newline ...
            folder]); 
    end
end

function bidsPath = convertRelativePathToAbsolute(bidsPath)
    if ~startsWith(bidsPath, '.')
        return
    end
    config = Configuration();
    config = config.loadConfiguration();
    bidsPath = fullfile(config.getDataPath(), bidsPath);
end