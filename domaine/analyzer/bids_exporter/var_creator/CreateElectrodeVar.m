function tsvElectrodeFile = CreateElectrodeVar(sFile)
            
    % Load Channel File
    channelFile = load(ChannelManager.getChannelFilePath(sFile));

    % Initialiaze tsvElectrodeFile variable with titles
    tsvElectrodeFile = strings([1,4]);
    count = 1;
    tsvElectrodeFile(count,:) = ["Name" "X coordinate" "Y coordinate" "Z coordinate"];
    count = count + 1;

    % Loop through every channel
    allChannels = channelFile.Channel;
    for i = 1:length(allChannels)
        location = allChannels(i).Loc;

        % Save information in tsvElectrodeFile variable
        tsvElectrodeFile(count,:) = [allChannels(i).Name, string(location(1)), ...
            string(location(2)), string(location(3))];
        count = count + 1;

    end

    % If position of all electrodes is 0
    if strcmp(unique(tsvElectrodeFile(2:end,:)), 0)
        waitfor(msgbox('The electrodes positions has not been added!'));
    end

end
          
