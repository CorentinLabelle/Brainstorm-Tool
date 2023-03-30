function [protocol_name, protocol_index] = protocol_get_current()
    protocol_info = bst_get('ProtocolInfo');
    protocol_name = protocol_info.Comment;
    protocol_index = protocol_get_index(protocol_name);