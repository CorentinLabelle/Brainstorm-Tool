function create_electrode_tsv_file(channel_file, path)
    electrode_tsv_var = create_electrode_tsv_var(channel_file);
    save_file(path, electrode_tsv_var);
end

function tsv_electrode_var = create_electrode_tsv_var(channel_file)

    % Initialiaze tsvElectrodeFile variable with titles
    tsv_electrode_var = strings([1,4]);
    count = 1;
    tsv_electrode_var(count,:) = ["name" "x" "y" "z"];
    count = count + 1;

    channels = channel_file.Channel;
    % Loop through every channel
    for iChannel = 1:length(channels)
        location = channels(iChannel).Loc;

        % Save information in tsvElectrodeFile variable
        channel_name = upper(channels(iChannel).Name);
        tsv_electrode_var(count,:) = [channel_name, string(location(1)), ...
            string(location(2)), string(location(3))];
        count = count + 1;

    end

    % If position of all electrodes is 0
    all_locations = {channels.Loc};
    bool = cellfun(@(x) isequal(x, [0;0;0]), all_locations);
    if all(bool)
        warning(['The EEG Positions have not been added for the following study: ' ...
                newline 'Subject: ' sFile.SubjectName ...
                newline 'Study: ' sFile.Condition ...
                newline 'Filename: ' sFile.FileName newline]);
    end

end
          
