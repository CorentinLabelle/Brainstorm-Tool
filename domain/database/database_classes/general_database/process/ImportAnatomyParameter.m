function parameters = ImportAnatomyParameter()
    p1 = ParameterFactory.create('subject', 'char', char.empty());
    p2 = ParameterFactory.create('anatomy_path', 'char', char.empty());
    p3 = ParameterFactory.create('file_format', 'char', char.empty(), getPossibleFileFormat());
    parameters = {p1, p2, p3};
end

function possibleFileFormat = getPossibleFileFormat()
    possibleFileFormat = {...
        'FreeSurfer-fast', ...
        'FreeSurfer', ...
        };
end