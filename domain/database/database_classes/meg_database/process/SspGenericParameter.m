function parameters = SspGenericParameter()
    p1 = ParameterFactory.create('event', 'char', char.empty());
    parameters = ListOfParameters(p1);
end