function protocol_delete(protocol_name)
    if ~protocol_is_created(protocol_name)
        warning(['Cannot delete protocol ''' protocol_name '''. Protocol does not exist.']);
    else
        gui_brainstorm('DeleteProtocol', protocol_name);
    end
end