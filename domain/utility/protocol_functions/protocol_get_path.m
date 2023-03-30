function path = protocol_get_path(protocol_name_or_index)
    protocol_set(protocol_name_or_index);
    protocol_info = bst_get('ProtocolInfo');
    path = bst_fullfile(bst_get('BrainstormDbDir'), protocol_info.Comment);
end