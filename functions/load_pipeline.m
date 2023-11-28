function sProcesses = load_pipeline(pipeline_path)

    % Check if pipeline exists
    if ~isfile(pipeline_path)
        error(['Pipeline not found: ' char(pipeline_path)]);
    end

    % Load pipeline
    [~, ~, extension] = fileparts(pipeline_path);
    switch extension
        case '.json'
            sProcesses = load_json_pipeline(pipeline_path);
        case '.mat'
            sProcesses = load_mat_pipeline(pipeline_path);
        otherwise
            error(['Invalid extension in pipeline path: ' char(extension)]);        
    end

end

%% Functions to load a MAT pipeline

function sProcesses = load_mat_pipeline(pipeline_path)
    sProcesses = load(pipeline_path);
    if isfield(sProcesses, 'Processes')
        sProcesses = sProcesses.Processes;
    end
end

%% Functions to load a JSON pipeline

function pipeline = load_json_pipeline(pipeline_path)
    pipeline = read_json(pipeline_path);

    if isfield(pipeline, 'Graph')
        version = 'v1';
        processes = pipeline.Graph.Nodes;
    elseif isfield(pipeline, 'Processes')
        version = 'v2';
        processes = pipeline.Processes;
    else
        error('Invalid pipeline.');
    end
    
    final_processes = cell(1, length(processes));
    for iProcess = 1:length(processes)
        
        if strcmp(version, 'v1')
            process_name = processes(iProcess).Process.Name;
            process_parameters = processes(iProcess).Process.Parameters;
        elseif strcmp(version, 'v2')
            process_name = processes(iProcess).Name;
            process_parameters = processes(iProcess).Parameters;
        end

        sProcess = process_load_sProcess(process_name);

        parameter_names = fieldnames(process_parameters);
        for iParameter = 1:length(parameter_names)
            parameter_name = parameter_names{iParameter};
            parameter_value = process_parameters.(parameter_name);

            if isfield(sProcess.options, parameter_name)
                parameter = sProcess.options.(parameter_name);
                sProcess.options.(parameter_name) = option_set_value(parameter, parameter_value);
            end

        end
        final_processes{iProcess} = sProcess;

    end
    
    pipeline = final_processes;
    pipeline = cell2mat(pipeline);
    
end


function sProcess = process_load_sProcess(process_name)
    sProcess = panel_process_select('LoadExternalProcess', process_name);
    if isempty(sProcess)
        error(['Process not found: ' process_name]);
    end
end 

%% Read json
function structure = read_json(json_path)            
    fileID = fopen(json_path);
    raw = fread(fileID, inf); 
    fclose(fileID);
    str = char(raw');
    structure = jsondecode(str);
    structure = convert_column_fields_to_row(structure);
end

function structure = convert_column_fields_to_row(structure)
    for i = 1:length(structure)
        fields = fieldnames(structure(i));
        for j = 1:length(fields)
            value = structure(i).(fields{j});
            if isstruct(value)
                value = convert_column_fields_to_row(value);
            elseif iscolumn(value)
                value = value';
            end
            structure(i).(fields{j}) = value;
        end
    end
end

