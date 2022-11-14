function parameters = BandPassFilterParameter()
    p1 = ParameterFactory.create('frequence', 'double', double.empty());
    p1 = p1.setValidityFunction(@BandPassFilterFrequenceValidity);
    parameters = p1;
end
    
function BandPassFilterFrequenceValidity(value)
    if ~isequal(size(value), [1, 2])
        error('The value for this parameter should be of size (1, 2).');
    end
end