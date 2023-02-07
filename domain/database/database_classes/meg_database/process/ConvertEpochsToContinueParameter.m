function parameters = ConvertEpochsToContinueParameter()
    p1 = ParameterFactory.create('to_run', 'logical', true);
    parameters = ListOfParameters(p1);
end