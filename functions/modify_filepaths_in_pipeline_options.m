function pipeline = modify_filepaths_in_pipeline_options(pipeline, additionnal_files)
% Modify the paths in the pipeline's options.
    
    % Loop over processes
    for iProcess = 1:length(pipeline)
        options = pipeline(iProcess).options;
        option_names = fieldnames(options);
        
        % Loop over options
        for iOption = 1:length(option_names)
            option_name = option_names{iOption};
            option = options.(option_name);
            
            if ismember(option.Type, {'filename', 'datafile'})
                original_path = option.Value{1, 1};
                
                % Get path relative to container
                final_path = find_file_in_container(original_path, additionnal_files);
                
                % Edit original option
                new_option = option_set_value(option, final_path);
                pipeline(iProcess).options.(option_name) = new_option;
                
                disp('Path modified:');
                disp([blanks(3) 'Original: ' original_path]);
                disp([blanks(3) 'Edited: ' final_path]);
                
            else
                continue
            end
        end
    end
    
end


function new_path = find_file_in_container(file_to_find, additional_files)
% Finds a file in the container input folder and modifies the original file
% path so it is found in the container.

    if isempty(additional_files)
       % No external file folder was given in input.
       error(...
           ['File not found in container, probably because no folder (for the addtional files) was given in input:' newline ...
           file_to_find]);
    end

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
        path_to_test = fullfile(additional_files, file_to_find_split{end-i+1:end});
        if search_function(path_to_test)
            new_path = path_to_test;
            break
        end
    end
    
    % If not found
    if isempty(new_path)
        error(['File not found in container:' newline file_to_find]);
    end
end
