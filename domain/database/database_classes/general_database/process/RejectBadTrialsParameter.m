function parameters = RejectBadTrialsParameter()
    p1 = ParameterFactory.create('meggrad',   'numeric', double.empty());
    p2 = ParameterFactory.create('megmag',    'numeric', double.empty());
    p3 = ParameterFactory.create('eeg',       'numeric', double.empty());
    p3 = p3.setValidityFunction(@RangeValidityFunction);
    p4 = ParameterFactory.create('seeg_ecog', 'numeric', double.empty());
    p5 = ParameterFactory.create('eog',       'numeric', double.empty());
    p6 = ParameterFactory.create('ecg',       'numeric', double.empty());
    
    p7 = ParameterFactory.create('time_window', 'numeric', double.empty());
    p7 = p7.setOptionnal();    
    p8 = ParameterFactory.create('rejection_type', 'char', 'only bad channel', getRejectionTypePossibleValue());
    p8 = p8.setConverterFunction(@rejectionTypeConverter);
    
    parameters = {p1, p2, p3, p4, p5, p6, p7, p8};
end
    
function rejectionTypePossibleValue = getRejectionTypePossibleValue()
    rejectionTypePossibleValue = {...
        'only bad channel', ...
        'entire trial'};
end
    
function rejectionTypeNumber = rejectionTypeConverter(rejectionTypeChar)
    switch rejectionTypeChar
        case 'only bad channel'
            rejectionTypeNumber = 1;
        case 'entire trial'
            rejectionTypeNumber = 2;
    end
end

function RangeValidityFunction(value)
    if ~isequal(size(value), [1, 2])
        error('The range should be of size (1, 2)');
    end
end
