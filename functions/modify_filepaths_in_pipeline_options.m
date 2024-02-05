function pipeline = modify_filepaths_in_pipeline_options(pipeline)
% Modify the paths in the pipeline's option.

    for iProcess = 1:length(pipeline)
        process = pipeline(iProcess);

        options = process.options;
        option_names = fieldnames(options);
        for iOption = 1:length(option_names)
            option_name = option_names{iOption};
            option = options.(option_name);

            if ismember(option.Type, {'filename', 'datafile'})
                original_path = option.Value{1, 1};
                final_path = find_file_in_container(original_path);
                new_option = option_set_value(option, final_path);
                pipeline(iProcess).options.(option_name) = new_option;
            else
                continue
            end
        end
    end
end


function new_path = find_file_in_container(file_to_find)
% Finds a file in the container input folder and modifies the original file
% path so it is found in the container.

    CONTAINER_INPUT_FOLDER = '/input';

    % Initialize
    new_path = '';

    % Check if looking for file or folder
    % The search_function handle needs to point to a function with the
    % following signature:
    % bool = search_function(path)
    [~, ~, extension] = fileparts(file_to_find);
    if isempty(extension)
        % Looking for folder
        search_function = @isfolder;
    else
        % Looking for file
        search_function = @isfile;
    end
    
    % Split original file paths
    file_to_find_split = strsplit(file_to_find, filesep);
    
    % Remove base folder and check existence
    for i = 1:length(file_to_find_split)
        path_to_test = fullfile(CONTAINER_INPUT_FOLDER, file_to_find_split{i:end});
        if search_function(path_to_test)
            new_path = path_to_test;
        end
    end
    
    % If not found
    if isempty(new_path)
        error(['File not found in container:' newline file_to_find]);
    end
end
