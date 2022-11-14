function parameters = DetectCardiacArtifactParameter()
    p1 = ParameterFactory.create('channel', 'char', 'ECG');
    p2 = ParameterFactory.create('event', 'char', 'cardiac');
    p3 = ParameterFactory.create('time_window', 'double', double.empty());
    p3 = p3.setOptionnal();
    parameters = {p1, p2, p3};