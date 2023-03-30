function process_name = process_unformat_name(process_name)
    prefix = 'process_';
    if startsWith(process_name, prefix)
        process_name = process_name(length(prefix)+1:end);
    end
    process_name = strrep(process_name, '_', ' ');
    indexes = strfind(process_name, ' ');
    process_name = char(process_name);
    process_name(indexes+1) = upper(process_name(indexes+1));
    process_name(1) = upper(process_name(1));
end