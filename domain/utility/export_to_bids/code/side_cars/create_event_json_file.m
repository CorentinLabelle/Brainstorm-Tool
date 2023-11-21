function create_event_json_file(sFile, path, event_descriptor_path)
    event_json_var = create_event_json_var(sFile, event_descriptor_path);
    save_file(path, event_json_var); 
end

function event_json_var = create_event_json_var(sFile, event_descriptor_path)
    arguments
        sFile
        event_descriptor_path char = char.empty();
    end
    
    if isempty(event_descriptor_path)
        event_description = struct.empty;
    else
        event_description = read_file(event_descriptor_path);
    end

    all_events = sFile_get_all_events(sFile);
    levels_struct = struct();
    for iEvent = 1:length(all_events)
        event = file_standardize(all_events{iEvent});
        if isfield(event_description, event)
            desc = event_description.(event);
        else
            desc = 'No description Available';
        end
        levels_struct.(event) = desc;        
    end
    
    % Get long name field
    if isfield(event_description, 'LongName')
        long_name = event_description.LongName;
    else
        long_name = 'Event category';
    end
    
    % Get description field
    if isfield(event_description, 'Description')
        description = event_description.Description;
    else
        description = 'Indicator of type of action that is expected';
    end
    
    s_.LongName = long_name;
    s_.Description = description;
    s_.Levels = levels_struct;
    event_json_var.trial_type = s_;            
end