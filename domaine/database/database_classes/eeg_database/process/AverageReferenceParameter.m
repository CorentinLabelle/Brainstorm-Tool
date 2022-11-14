function parameters = AverageReferenceParameter()
    p1 = ParameterFactory.create('eeg_reference', 'char', 'AVERAGE', getPossibleAverageReference());
    p1 = p1.setOptionnal();
    parameters = p1;
end

function possibleAverageReference = getPossibleAverageReference()
    possibleAverageReference = {...
        'AVERAGE', ...
        'LOCAL AVERAGE'};
end