function CreateProtocol(protocolName)
    arguments
        protocolName = 'New_Protocol';
    end
        
    if ProtocolManager.isProtocolCreated(protocolName)
        warning(['This protocol is already created "' protocolName '"']);
        return
    end
    ProtocolManager.createProtocol(protocolName);
    assert(strcmpi(bst_get('ProtocolInfo').Comment, protocolName))