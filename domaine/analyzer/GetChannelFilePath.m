function path = GetChannelFilePath(sFile)
            
    channelFile = string({sFile.ChannelFile});

    path = fullfile(PathsGetter.getBstDatabaseFolder(), ...
                    bst_get('ProtocolInfo').Comment, ...
                    'data', channelFile);
        
end