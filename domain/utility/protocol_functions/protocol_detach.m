function is_removed = protocol_detach(protocol_name_or_index)
    protocol_set(protocol_name_or_index);
    ask_user = false;
    delete_files = false;
    is_removed = db_delete_protocol(ask_user, delete_files);
end