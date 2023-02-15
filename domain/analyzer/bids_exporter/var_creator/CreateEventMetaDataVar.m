function s = CreateEventMetaDataVar(sFile, eventDescriptorPath)
    arguments
        sFile
        eventDescriptorPath char = double.empty
    end
    
    if isempty(eventDescriptorPath)
        eventDescription = struct.empty;
    else
        eventDescription = FileReader.read(eventDescriptorPath);
    end

    % Load list of all events
    allEvents = EventManager.getAllEvents(sFile);

    % Loop through every event
    for i = 1:length(allEvents)
        
        event = formatEventName(allEvents{i});

        % If eventDescription has a field 'event'
        if isfield(eventDescription, event)

            % Get event description
            desc = eventDescription.(event);

        else
            % Default event description
            desc = 'No description Available';
        end

        s__.(event) = desc;
        
    end

    s_.LongName = 'Event category';
    s_.Description = 'Indicator of type of action that is expected';
    s_.Levels = s__;

    s.trial_type = s_;
            
end