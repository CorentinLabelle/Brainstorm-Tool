function process_name = process_format_name(process_name)
    if isfile(process_name)
        [~, process_name] = fileparts(process_name);
    end
    if endsWith(process_name, '.m')
        process_name = process_name(1:end-2);
    end
    prefix = 'process_';
    if ~startsWith(process_name, prefix)
        process_name = [prefix process_name];
    end
    if endsWith(process_name, '_py')
        process_name = process_name(1:end-3);
    end
    process_name = strtrim(process_name);
    process_name = lower(process_name);
    process_name = strrep(process_name, ' ', '_');
end
        