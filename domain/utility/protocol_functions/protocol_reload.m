function protocol_reload(protocol_name_or_index)
    index = protocol_get_index(protocol_name_or_index);
    db_reload_database(index);
end