function protocol_create(protocol_name, name_value_args)
    arguments
        protocol_name char;
        name_value_args.DefaultAnatomy logical = 0;
        name_value_args.DefaultChannel logical = 0;
    end
    
    if protocol_is_created(protocol_name)
        protocol_set(protocol_name);
        warning(['The protocol ''' protocol_name ''' is already created.' newline ...
                'Instead, the protocol has been set as the current protocol.']);
    else    
        gui_brainstorm(...
            'CreateProtocol', ...
            protocol_name, ...
            name_value_args.DefaultAnatomy, ...
            name_value_args.DefaultChannel);
    end
end