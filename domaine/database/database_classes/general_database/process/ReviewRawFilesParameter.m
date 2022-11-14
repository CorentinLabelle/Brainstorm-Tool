function parameters = ReviewRawFilesParameter()
    p1 = ParameterFactory.create('subject', 'cell', cell.empty());
    p2 = ParameterFactory.create('raw_files', 'cell', cell.empty());
    p2 = p2.setConverterFunction(@RawFilesConverter);
    p3 = ParameterFactory.create('file_format', 'char', char.empty(), getPossibleFileFormat());
    parameters = {p1, p2, p3};
end
    
function possibleFileFormat = getPossibleFileFormat()
    possibleFileFormat = {...
        'EEG-DELTAMED', ...
        'EEG-BRAINAMP', ...
        'EEG-EDF', ...
        'CTF', ...
        };
end

function value = RawFilesConverter(value)
    if all(cellfun(@(x) isa(x, 'char'), value))
        value = {value};
    end
end