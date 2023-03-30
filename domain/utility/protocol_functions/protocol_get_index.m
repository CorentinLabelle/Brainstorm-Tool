function index = protocol_get_index(protocol_name_or_index)
    if isnumeric(protocol_name_or_index)
        index = protocol_name_or_index;
    else
        index = bst_get('Protocol', protocol_name_or_index);
    end    
    if isempty(index)
    	error(['Protocol ''' protocol_name_or_index ''' has not been found.']);
    end
end