function tsvChannelFile = CreateChannelVar(sFile)

    % Load Channel File
    channelFile = load(ChannelManager.getChannelFilePath(sFile));
    studyMatFile = load(fullfile(PathsGetter.getBstDatabaseFolder(), bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));
    channelFlag = studyMatFile.ChannelFlag;

    % Initialiaze tsvElectrodeFile variable with titles
    tsvChannelFile = strings([1,5]);
    count = 1;
    tsvChannelFile(count,:) = ["name" "type" "units" "group" "status"];
    count = count + 1;

    % Loop through every channel
    allChannels = channelFile.Channel;
    for i = 1:length(allChannels)        
        group = allChannels(i).Group;
        if isempty(group)
            group = "n/a";
        end        
        status = "good";
        if channelFlag(i) == -1
            status = "bad";
        end

        % Save information in tsvChannelFile variable        
        row = [allChannels(i).Name, allChannels(i).Type, "uV", group, status];
        tsvChannelFile(count,:) = row;
        count = count + 1;

    end
   
end
        