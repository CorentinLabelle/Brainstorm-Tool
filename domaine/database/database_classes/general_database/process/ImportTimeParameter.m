function parameters = ImportTimeParameter()
    p1 = ParameterFactory.create('time_window', 'numeric', double.empty());
    p1 = p1.setOptionnal();
    parameters = p1;