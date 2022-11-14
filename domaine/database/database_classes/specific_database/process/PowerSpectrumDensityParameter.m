function parameters = PowerSpectrumDensityParameter()
    p1 = ParameterFactory.create('window_length', 'double', double.empty());
    p2 = ParameterFactory.create('window_overlap', 'double', 50);
    p2 = p2.setOptionnal();
    parameters = {p1, p2};