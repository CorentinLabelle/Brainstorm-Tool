function CoordSys = CreateCoordinateVar(sFile)
            
    % Load channel file
    channelFile = load(ChannelManager.ChannelManager.getChannelFilePath(sFile));

    indexOfAddLocEntry = find(strcmp(channelFile.History(:,2), 'addloc'));
    coordSystem = 'MNIColin27'; % Default
    if ~isempty(indexOfAddLocEntry)
        if contains(channelFile.History(indexOfAddLocEntry,3), 'BrainProducts')
            coordSystem = 'MNIColin27';
        end
    else
        warning(['The EEG Positions have not been added for the following study: ' ...
                newline 'Subject: ' sFile.SubjectName ...
                newline 'Study: ' sFile.Condition ...
                newline 'Filename: ' sFile.FileName newline]);
    end 

    CoordSys = struct();
    CoordSys.EEGCoordinateSystem = coordSystem;
    CoordSys.EEGCoordinateUnit = 'm';
    
end