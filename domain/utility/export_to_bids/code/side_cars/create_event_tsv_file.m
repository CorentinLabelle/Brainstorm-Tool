function create_event_tsv_file(sFile, path)
    event_tsv_var = create_event_tsv_var(sFile);
    save_file(path, event_tsv_var);
end

function event_tsv_var = create_event_tsv_var(sFile)
    % Create TSV file that lists the events with time and duration.

    % Input>    cFiles [cell]
    %           destination [char]: path indicating where to save the TSV file 

    % Load Event structure
    study_mat_file = load(fullfile(bst_get('BrainstormDbDir'), bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));
    event_structure = study_mat_file.F.events;

    % Initialiaze tsvFile variable with titles
    event_tsv_var = strings([1,3]);
    count = 1;
    event_tsv_var(count,:) = ["onset" "duration" "trial_type"];
    count = count + 1;

    % Loop through every event types
    for iEvent = 1:length(event_structure)

        % Loop through all time (each occurence of an event)
        for iTime = 1:length(event_structure(iEvent).times)

            % Save information in tsvFile variable
            event_name = (event_structure(iEvent).label);
            event_name = file_standardize(event_name);
            event_tsv_var(count,:) = [event_structure(iEvent).times(iTime) 0 string(event_name)];
            count = count + 1;
        end
    end

end
        
