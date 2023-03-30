function protocol_set(protocol_name_or_index)
    index = protocol_get_index(protocol_name_or_index);
    bst_set('iProtocol', index);
    gui_brainstorm('SetCurrentProtocol', index);
end