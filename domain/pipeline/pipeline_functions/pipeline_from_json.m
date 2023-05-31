function pipeline = pipeline_from_json(file_path)
    jsonVar = read_file(file_path);
    
    pipeline = pipeline_create();
    
    pipeline.set_file(file_path);
    
    if isfield(jsonVar, 'Extension')
        pipeline.set_extension(jsonVar.Extension);
    end
    
    if isfield(jsonVar, 'Date')
        pipeline.set_date(jsonVar.Date);
    end
    
    graph = process_graph_create(jsonVar.Graph);
    pipeline.set_graph(graph);
    
end