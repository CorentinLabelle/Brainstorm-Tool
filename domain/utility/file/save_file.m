function save_file(filePath, variableToSave)
    [~, ~, extension] = fileparts(filePath);            
    if strcmpi(extension, '.tsv')
        function_handle = @save_to_tsv;
    elseif strcmp(extension, '.json')
        function_handle = @save_to_json;
    elseif strcmp(extension, '.mat')
        function_handle = @save_to_mat;
    end
    function_handle(filePath, variableToSave);            
end

function path = save_to_tsv(path, variable_to_save)
    if ~iscell(variable_to_save)
        variable_to_save = cellstr(variable_to_save);
    end
    writecell(variable_to_save, path, 'filetype', 'text', 'delimiter', '\t');
end

function path = save_to_json(path, variable_to_save)
    fileID = fopen(path, 'wt');
    variable_to_save = jsonencode(variable_to_save, 'PrettyPrint', true);
    fprintf(fileID, variable_to_save);
    fclose(fileID);
end

function path = save_to_mat(path, variable_to_save)
    save(path, "variable_to_save");
end