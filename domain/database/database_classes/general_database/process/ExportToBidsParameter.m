function parameters = ExportToBidsParameter()
    p1 = ParameterFactory.create('folder', 'char', char.empty());
    p2 = ParameterFactory.create('event_descriptor', 'char', char.empty());
    p2 = p2.setOptionnal();
    p3 = ParameterFactory.create('project_name', 'char', char.empty());
    p3 = p3.setOptionnal();
    p4 = ParameterFactory.create('project_id', 'char', char.empty());
    p4 = p4.setOptionnal();
    p5 = ParameterFactory.create('project_description', 'char', char.empty());
    p5 = p5.setOptionnal();
    p6 = ParameterFactory.create('participant_description', 'char', char.empty());
    p6 = p6.setOptionnal();
    p7 = ParameterFactory.create('task_description', 'char', char.empty());
    p7 = p7.setOptionnal();
    p8 = ParameterFactory.create('dataset_desc_json', 'struct', struct.empty());
    p8 = p8.setOptionnal();
    parameters = {p1, p2, p3, p4, p5, p6, p7, p8};
end