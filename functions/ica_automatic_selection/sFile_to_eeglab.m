function EEG = sFile_to_eeglab(sFile, ica_recording, iChannels, icaweights, icasphere)
    arguments
       sFile;
       ica_recording = [];
       iChannels = [];
       icaweights = [];
       icasphere = [];
    end
    
    if ~isstruct(sFile)
        sFile = sFile_to_struct(sFile);
    end
    if ~sFile_is_raw(sFile)
        error('To convert an sFile to eeglab, the sFile has to be raw (for now...)');
    end

    study_path = sFile_get_study_path(sFile);
    study = load(study_path);
    
    channel_path = sFile_get_channel_file_path(sFile);
    channel_file = load(channel_path);
    
    [recording, ~] = sFile_get_recording(sFile);
    
    %% sFile to EEGLAB struct
    % https://eeglab.org/tutorials/ConceptsGuide/Data_Structures.html#eeg-and-alleeg
    % https://github.com/sccn/eeglab/blob/develop/functions/adminfunc/eeg_checkset.m

    EEG = struct();
    EEG.setname = '';
    EEG.filename = sFile.FileName;
    EEG.filepath = fileparts(sFile.FileName);
    EEG.subject = sFile.SubjectName;
    EEG.group = [];
    EEG.condition = sFile.Condition;
    EEG.session = [];
    EEG.comments = sFile.Comment;
    EEG.trials = 1;
    EEG.pnts = study.Time(end) * study.F.prop.sfreq; %study.F.header.nsamples;
    EEG.srate = study.F.prop.sfreq;
    EEG.xmin = study.Time(1);
    EEG.xmax = study.Time(end);
    EEG.times = study.Time;
    EEG.ref = [];
    EEG.history = [];
    EEG.data = recording;
    EEG.etc = [];
    EEG.saved = [];
    EEG = create_channel_fields(channel_file, EEG);
    EEG = create_event_fields(sFile, EEG);
    EEG = create_ica_fields(ica_recording, iChannels, icaweights, icasphere, EEG);

    % EEGLAB check set
    [eeg_final, res] = eeg_checkset(EEG);
end

function EEG = create_ica_fields(F, iChannels, icaweights, icasphere, EEG)
    if nargin == 1
        EEG = struct();
    end
    
    EEG.icaweights = icaweights;
    EEG.icasphere = icasphere;
    
    % W: Unmixing matrix
    W = icaweights * icasphere;
    
    % EEG.icawinv = pinv(EEG.icaweights * EEG.icasphere) = pinv(W)
    EEG.icawinv = pinv(W);

    % EEG.icaact = EEG.icaweights*EEG.icasphere)*EEG.data
    EEG.icaact = [];
    if ~isempty(W)
        EEG.icaact = W * F;
    end
    
    EEG.icachansind = iChannels;
end

function EEG = create_event_fields(sFile, EEG)
    if nargin == 1
        EEG = struct();
    end
    
    % Load event structure
    study_mat_file = load(sFile_get_study_path(sFile));
    event_struct = study_mat_file.F.events;
    
    EEG.event = create_event_field(event_struct);
    EEG.urevent = [];
    EEG.epoch = [];
    EEG.eventdescription = [];
    EEG.epochdescription = [];
    
end

function event = create_event_field(event_struct)
    event = [];
    for iEvent = 1:length(event_struct)
        current_event = event_struct(iEvent);
        for iTime = 1:size(current_event.times, 2)
            idx = length(event) + 1;
            event(idx).type = current_event.label;
            event(idx).latency = current_event.times(1, iTime);
            event(idx).epoch = current_event.epochs(iTime);
            
            if size(current_event.times, 1) == 2
                event(idx).duration = current_event.times(2, iTime) - current_event.times(1, iTime);
            else
                event(idx).duration = double.empty;
            end
        end        
    end
    table = struct2table(event);
    sorted_table = sortrows(table, 'latency');
    event = table2struct(sorted_table);
end

function EEG = create_channel_fields(channel_file, EEG)
    if nargin == 1
        EEG = struct();
    end
    EEG.urchanlocs = create_urchanlocs_field(channel_file);
    EEG.chanlocs = create_chanlocs_field(EEG.urchanlocs);
    EEG.nbchan = length(channel_file.Channel);
    EEG.chaninfo = struct('comment', channel_file.Comment);
    EEG.ref = 'average';
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


%% SFiles functions

function path = sFile_get_study_path(sFile)
    database_directory = bst_get('BrainstormDbDir');
    path = fullfile(database_directory, bst_get('ProtocolInfo').Comment, 'data', sFile.FileName);
end

function sFiles = sFile_to_struct(study_link)
    arguments
        study_link string
    end            
    if isempty(study_link)
        sFiles = [];
        return
    end
    for iLink = 1:length(study_link)
        link = study_link{iLink};
        link_parts = string(strsplit(link, filesep));
        link = fullfile(link_parts{end-2:end});
        sFiles(iLink) = database_searcher_search_query("path", "equals", link);
    end            
end

function [recording, time_vector] = sFile_get_recording(sFile)
    LoadOptions = [];
    rawTime = [];
    sMat = ...
        bst_process('LoadInputFile', sFile.FileName, [], rawTime, LoadOptions);
    recording = sMat.Data;
    time_vector = sMat.Time;
end

function isRaw = sFile_is_raw(sFile)
    isRaw = strcmpi(sFile.FileType, 'raw');
end

function path = sFile_get_channel_file_path(sFile)
    channelFile = string({sFile.ChannelFile});
    path = fullfile(bst_get('BrainstormDbDir'), ...
            bst_get('ProtocolInfo').Comment, ...
            'data', channelFile);        
end
