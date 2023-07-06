function all_events = sFile_get_all_events(sFiles)
    all_events = string.empty();
    for i = 1:length(sFiles)
        study_mat_file = load(sFile_get_study_path(sFiles(i)));
        event_struct = study_mat_file.F.events;
        for j = 1:length(event_struct)
            if ~any(strcmpi(all_events, event_struct(j).label))
                all_events = [all_events string(event_struct(j).label)];
            end
        end
    end
end