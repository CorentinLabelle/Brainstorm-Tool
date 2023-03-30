function command = value_to_command(input)
    
    switch class(input)       
        case 'double'
            command = from_double(input);
        case 'string'
            command = from_string(input);
        case 'char'
            command = from_string(input);
        case 'cell'
            command = from_cell(input);
        case 'struct'
            command = from_struct(input);
        case 'logical'
            command = from_logical(input);
        otherwise
            error(class(input));
    end

end

function command = from_double(int)
    command = mat2str(int);
end

function command = from_string(str)
    character = char(str);
    command = ['''' character ''''];
end

function command = from_cell(c)
    str = strings(1, length(c));
    for i = 1:length(c)
       str{i} = value_to_command(c{i});
    end
    command = ['{' char(strjoin(str, ', ')) '}'];
end

function command = from_struct(s)
    field_names = fields(s);
    str = strings(1, length(field_names));
    for i = 1:length(field_names)
       name_command = value_to_command(field_names{i});
       value_command = value_to_command(s.(field_names{i}));
       if iscell(s.(field_names{i}))
           value_command = ['{' value_command '}'];
       end
       str{i} = [name_command ', ' value_command];
    end
    command = ['struct(' char(strjoin(str, ', ')) ')'];
end

function command = from_logical(bool)
    if bool
        command = '1';
    else
        command = '0';
    end
end