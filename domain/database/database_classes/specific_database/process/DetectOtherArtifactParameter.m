function parameters = DetectOtherArtifactParameter()
    p1 = ParameterFactory.create('low_frequence', 'logical', false);
    p2 = ParameterFactory.create('high_frequence', 'logical', false);
    p3 = ParameterFactory.create('time_window', 'double', double.empty());
    p3 = p3.setOptionnal();
    parameters = {p1, p2, p3};