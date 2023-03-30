function process = process_create(input)
    switch class(input)
        case 'char'
            process = from_char(input);
        case 'struct'
            process = from_struct(input);
        otherwise
            error('Invalid Input');
    end
    if iscell(process) && length(process) == 1
        process = process{1};
    end
end

function process = from_char(name)
    process_name = process_format_name(name);
    process = Process(process_name);
end

function process = from_struct(s)
    assert(isfield(s, 'Name'));
    assert(isfield(s, 'Parameters'));
    process = cell(1, length(s));
    for i = 1:length(s)
        process_name = s(i).Name;
        process{i} = from_char(process_name);
        option_names = fields(s(i).Parameters);
        for j = 1:length(option_names)
            process{i}.set_option(option_names{j}, s(i).Parameters.(option_names{j}));
        end
    end
end