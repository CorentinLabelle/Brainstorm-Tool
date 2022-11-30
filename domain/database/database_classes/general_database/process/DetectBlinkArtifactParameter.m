function parameters = DetectBlinkArtifactParameter()
    p1 = ParameterFactory.create('channel', 'char', 'EOG');
    p2 = ParameterFactory.create('event', 'char', 'blink');
    p3 = ParameterFactory.create('time_window', 'double', double.empty());
    p3 = p3.setOptionnal();
    parameters = {p1, p2, p3};