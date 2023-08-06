function EEG = create_channel_fields(channel_file, EEG)
    if nargin == 1
        EEG = struct();
    end
    EEG.urchanlocs = create_urchanlocs_field(channel_file);
    EEG.chanlocs = create_chanlocs_field(EEG.urchanlocs);
    EEG.nbchan = create_nbchan_field(channel_file);
    EEG.chaninfo = create_chaninfo_field(channel_file);
    EEG.ref = create_ref_field(channel_file);
    EEG.splinefile = [];
end

function urchanlocs = create_urchanlocs_field(channel_file)
    urchanlocs = cell(1, length(channel_file.Channel));
    for iChannel = 1:length(channel_file.Channel)
        current_channel = channel_file.Channel(iChannel);        
        urchanlocs{iChannel}.labels = current_channel.Name;
        urchanlocs{iChannel}.X = current_channel.Loc(1);
        urchanlocs{iChannel}.Y = current_channel.Loc(2);
        urchanlocs{iChannel}.Z = current_channel.Loc(3);
    end
    urchanlocs = [urchanlocs{:}];
    urchanlocs = convertlocs(urchanlocs, 'cart2all');
end

function chanlocs = create_chanlocs_field(urchanlocs)  
    % Remove electrodes with position (0, 0, 0)
    positions = [urchanlocs.X; urchanlocs.Y; urchanlocs.Z];
    electrodes_with_no_location = all(positions == 0);
    chanlocs = urchanlocs(~electrodes_with_no_location);
    chanlocs = urchanlocs;
end

function chaninfo = create_chaninfo_field(channel_file)
    chaninfo.comment = channel_file.Comment;
end

function ref = create_ref_field(~)
    ref = 'average';
end

function nbchan = create_nbchan_field(channel_file)
    nbchan = length(channel_file.Channel);
end
