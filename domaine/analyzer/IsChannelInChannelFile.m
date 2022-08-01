function IsChannelInChannelFile(sFiles, channelToCheck)
            
    channelFilePaths = GetChannelFilePath(sFiles);

    for i = 1:length(channelFilePaths)
        channelFile = load(channelFilePaths(i));

        if ~any(strcmp(channelToCheck, {channelFile.Channel.Name}))
            error(['The study ' sFiles(i).Condition, ...
                ' does not contain the channel ' channelToCheck '.']);
        end

    end
    
end