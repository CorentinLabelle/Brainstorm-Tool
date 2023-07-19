function event_struct = sFile_get_event_structure(sFiles)
    study_mat_file = load(sFile_get_study_path(sFiles));
    event_struct = study_mat_file.F.events;
end