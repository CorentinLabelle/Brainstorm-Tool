function structure = read_file(file_path)
    if ~isfile(file_path)
        error(['The following path does not exist:' newline file_path]);
    end
    [~, ~, extension] = fileparts(file_path);            
    if strcmpi(extension, '.json')
        function_handle = @read_json;
    elseif strcmpi(extension, '.mat')
        function_handle = @read_mat;
    else
        error(['The file format ' extension ' is not supported!']);
    end
    structure = function_handle(file_path);            
end

function structure = read_mat(path)
    structure = load(path);            
end

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