function pipeline = pipeline_create(file_path)
    arguments
        file_path = [];
    end
    if isempty(file_path)
        pipeline = Pipeline();
    else
        pipeline = from_file(file_path);
    end    
end
    
function pipeline = from_file(file_path)
    assert(isfile(file_path), ['Input is not an existing file:' newline file_path]);
    [~, ~, extension] = fileparts(file_path);
    switch extension
        case '.json'
            pipeline = pipeline_from_json(file_path);
        case '.mat'
            pipeline = from_mat(file_path);
        otherwise
            error(['Invalid extension (' char(extension) '). Cannot create pipeline.']);
    end
    pipeline.set_file(file_path);
end

function pipeline = from_mat(file_path)
    mat_struct = read_file(file_path);
    fields = fieldnames(mat_struct);
    assert(length(fields) == 1);
    pipeline = mat_struct.(fields{1});
end