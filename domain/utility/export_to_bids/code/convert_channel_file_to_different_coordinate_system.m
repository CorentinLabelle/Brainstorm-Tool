function new_channel_file = convert_channel_file_to_different_coordinate_system(sFile, src_cs, dest_cs)
    
    sMri_path = sFile_get_sMri_path(sFile);
    sMri = load(sMri_path);
    
    original_channel_file_path = sFile_get_channel_file_path(sFile);
    original_channel_file = load(original_channel_file_path);
    
    new_channel_file = original_channel_file;
    
    % Headpoints field
    headpoints_loc = new_channel_file.HeadPoints.Loc;
    converted_headpoints = cs_convert(sMri, src_cs, dest_cs, headpoints_loc);
    new_channel_file.HeadPoints.Loc = converted_headpoints';
    
    % Channel field    
    channel_locations = [new_channel_file.Channel.Loc];
    converted_channel_locations = cs_convert(sMri, src_cs, dest_cs, channel_locations);
    converted_channel_locations = converted_channel_locations';
    for iChan = 1:length(new_channel_file.Channel)
        new_channel_file.Channel(iChan).Loc = converted_channel_locations(:, iChan);
    end
    
end