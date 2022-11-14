classdef ChannelManager
    
    methods (Static, Access = public)
        
        function path = getChannelFilePath(sFile)            
            channelFile = string({sFile.ChannelFile});
            path = fullfile(PathsGetter.getBstDatabaseFolder(), ...
                    bst_get('ProtocolInfo').Comment, ...
                    'data', channelFile);        
        end
        
        function IsChannelInChannelFile(sFiles, channelToCheck)            
            channelFilePaths = ChannelManager.getChannelFilePath(sFiles);
            for i = 1:length(channelFilePaths)
                channelFile = load(channelFilePaths(i));
                if ~any(strcmp(channelToCheck, {channelFile.Channel.Name}))
                    error(['The study ' sFiles(i).Condition, ...
                        ' does not contain the channel ' channelToCheck '.']);
                end
            end    
        end

    end
    
end