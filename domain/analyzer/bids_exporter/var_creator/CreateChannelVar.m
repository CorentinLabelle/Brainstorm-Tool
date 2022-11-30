function tsvChannelFile = CreateChannelVar(sFile)

    % Load Channel File
    channelFile = load(ChannelManager.getChannelFilePath(sFile));

    % Initialiaze tsvElectrodeFile variable with titles
    tsvChannelFile = strings([1,3]);
    count = 1;
    tsvChannelFile(count,:) = ["name" "type" "units"];
    count = count + 1;

    % Loop through every channel
    allChannels = channelFile.Channel;
    for i = 1:length(allChannels)

        % Save information in tsvChannelFile variable
        tsvChannelFile(count,:) = [allChannels(i).Name, allChannels(i).Type, "uV"];
        count = count + 1;

    end
   
end
        