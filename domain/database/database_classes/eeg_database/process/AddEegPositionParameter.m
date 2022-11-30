function parameters = AddEegPositionParameter()
    p1 = ParameterFactory.create('electrode_file', 'char', char.empty());
    p1 = p1.setValidityFunction(@electrodeFileValidity);
    p2 = ParameterFactory.create('file_format', 'char', char.empty(), getPossibleFileFormat());
    p3 = ParameterFactory.create('cap', 'char', char.empty(), getPossibleCaps());
    p3 = p3.setConverterFunction(@convertCapNameToCapNumber);
    parameters = ListOfParameters({p1, p2, p3});
    parameters = parameters.setValidityFunction(@verifyAddEegParameters);
end

function possibleCap = getPossibleCaps()
    possibleCap = {'Colin27: BrainProducts EasyCap 128'};
end

function possibleFileType = getPossibleFileFormat()
    possibleFileType = {'XENSOR'};
end

function capNumber = convertCapNameToCapNumber(capName)
    switch capName
        case 'Colin27: BrainProducts EasyCap 128'
            capNumber = 22;
        case char.empty()
            capNumber = 1;
        otherwise
            error('Invalid cap name');
    end
end

function electrodeFileValidity(electrodeFile)
    if ~isempty(electrodeFile)
        if ~isfile(electrodeFile)
            error('The electrode file is not a valid file.');
        end
    end
end

% Verify
function listOfParameters = verifyAddEegParameters(listOfParameters)
    electrodeFile = listOfParameters.getConvertedValue(1);

    if ~isempty(electrodeFile)
        capNumber = listOfParameters.getConvertedValue(3);
        if capNumber ~= 1
            listOfParameters = listOfParameters.setValue(3, char.empty());
        end
    end
            
end