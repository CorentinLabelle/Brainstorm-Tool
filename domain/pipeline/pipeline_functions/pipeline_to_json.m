function s = pipeline_to_json(pipeline)
    s = struct();
    %s.Folder = pipeline.get_folder();
    s.Name = pipeline.get_name();
    s.Extension = pipeline.get_extension();
    s.Date = pipeline.get_date();
    s.Graph = pipeline.Graph;
end