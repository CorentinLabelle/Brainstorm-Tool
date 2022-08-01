function path = GetChannelFilePath(sFile)
            
    channelFile = string({sFile.ChannelFile});

    path = fullfile(GetDatabasePath(), bst_get('ProtocolInfo').Comment, ...
                    'data', channelFile);
        
end