function pipeline = pipeline_from_json(file_path)
    jsonVar = read_file(file_path);
    
    pipeline = pipeline_create();
    pipeline.set_name(jsonVar.Name);
    %pipeline.set_folder(jsonVar.Folder);
    pipeline.set_extension(jsonVar.Extension);
    pipeline.set_date(jsonVar.Date);
    
    graph = process_graph_create(jsonVar.Graph);
    pipeline.set_graph(graph);
    
end