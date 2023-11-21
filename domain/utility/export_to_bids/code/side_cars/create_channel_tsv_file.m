function create_channel_tsv_file(sFile, path, isEeg)
    if isEeg
        channel_var = create_channel_var_EEG(sFile);
    else
        channel_var = create_channel_var_MEG(sFile);
    end
    save_file(path, channel_var); 
end

function tsv_channel_file = create_channel_var_EEG(sFile)

    % Load Channel File
    channel_file = load(sFile_get_channel_file_path(sFile));
    study_mat_file = load(fullfile(bst_get('BrainstormDbDir'), bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));
    channel_flag = study_mat_file.ChannelFlag;

    % Initialiaze tsvElectrodeFile variable with titles
    tsv_channel_file = strings([1,5]);
    count = 1;
    tsv_channel_file(count,:) = ["name" "type" "units" "group" "status"];
    count = count + 1;

    % Loop through every channel
    all_channels = channel_file.Channel;
    for iChannel = 1:length(all_channels)
        current_channel = all_channels(iChannel);    
        group = all_channels(iChannel).Group;
        if isempty(group)
            group = "n/a";
        end        
        status = "good";
        if channel_flag(iChannel) == -1
            status = "bad";
        end
        
        bids_type = get_bids_type_from_channel(current_channel);
        channel_name = upper(current_channel.Name);

        % Save information in tsvChannelFile variable        
        row = [channel_name, bids_type, "uV", group, status];
        tsv_channel_file(count,:) = row;
        count = count + 1;

    end
   
end

function tsv_channel_file = create_channel_var_MEG(sFile)

    % Load Channel File
    channel_file = load(sFile_get_channel_file_path(sFile));
    study_mat_file = load(fullfile(bst_get('BrainstormDbDir'), bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));
    channel_flag = study_mat_file.ChannelFlag;

    % Initialiaze tsvElectrodeFile variable with titles
    tsv_channel_file = strings([1,5]);
    count = 1;
    tsv_channel_file(count,:) = ["name" "type" "units" "group" "status"];
    count = count + 1;

    % Loop through every channel
    all_channels = channel_file.Channel;
    for iChannel = 1:length(all_channels)  
        current_channel = all_channels(iChannel);
        
        group = upper(current_channel.Group);
        if isempty(group)
            group = "n/a";
        end        
        status = "good";
        if channel_flag(iChannel) == -1
            status = "bad";
        end

        bids_type = get_bids_type_from_channel(current_channel);
        
        channel_name = upper(current_channel.Name);
        
        row = [channel_name, bids_type, "uV", group, status];
        tsv_channel_file(count,:) = row;
        count = count + 1;

    end
   
end

function bids_type = get_bids_type_from_channel(channel)
% https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/02-magnetoencephalography.html#channels-description-_channelstsv

    channel_type = channel.Type;
    switch channel_type        
        case 'Stim'
            bids_type = 'TRIG';
        case 'SysClock'
            bids_type = 'SYSCLOCK';
        case 'Misc'
            bids_type = 'MISC';
        case 'MEG REF'
            bids_type = get_meg_ref_type(channel);
        case 'MEG'
            bids_type = get_meg_type(channel);
        case {'ADC A', 'ADC V'}
            bids_type = 'ADC';
        case 'FitErr'
            bids_type = 'FITERR';
        case 'Other'
            bids_type = 'OTHER';
        case 'EEG_NO_LOC'
            bids_type = 'EEG';
        case {'ECG', 'EOG', 'DAC', 'HLU', 'EEG'}
            bids_type = channel_type;
        otherwise
            error([channel_type ': Channel type not supported yet.']);
    end
end

function bids_type = get_meg_ref_type(channel)
    channel_comment = channel.Comment;
    if contains(channel_comment, 'magnetometer')
       bids_type = 'MEGREFMAG';
    elseif contains(channel_comment, 'gradiometer')
       bids_type = 'MEGREFGRADAXIAL';
    else
       error([channel_comment ': Channel comment not supported yet.']);
    end
end

function bids_type = get_meg_type(channel)
    channel_comment = channel.Comment;
    if contains(channel_comment, 'axial gradiometer')
       bids_type = 'MEGGRADAXIAL';
    else
       error([channel_comment ': Channel comment not supported yet.']);
    end
end
