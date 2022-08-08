function s = CreateEventMetaDataVar(sFile)
               
    %eventDescriptonCreator = EventDescriptonStructureCreator(sFile);
    %eventDescriptionsPath = eventDescriptonCreator.getEventDescriptionFilePath();
    eventDescriptionsPath = char.empty();
    
    if isempty(eventDescriptionsPath)
        eventDescription = struct.empty;
    else
        eventDescription = FileReader.read(eventDescriptorPath);
    end

    % Load list of all events
    allEvents = GetAllEvents(sFile);

    % Loop through every event
    for i = 1:length(allEvents)

    % Replace '-' with '_'
    event = strrep(allEvents{i}, '-', '_');

    % Replace ' ' with '_'
    event = strrep(event, ' ', '_');

    % Check if character is a digit
    isDigit = isstrprop(event, 'digit');

    % If first character is a digit
    if (isDigit(1))
        event = "f" + event;
    end

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