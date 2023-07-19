function all_events = sFile_get_all_events(sFiles)
    all_events = string.empty();
    for i = 1:length(sFiles)
        event_struct = sFile_get_event_structure(sFiles(i));
        for j = 1:length(event_struct)
            if ~any(strcmpi(all_events, event_struct(j).label))
                all_events = [all_events string(event_struct(j).label)];
            end
        end
    end
end