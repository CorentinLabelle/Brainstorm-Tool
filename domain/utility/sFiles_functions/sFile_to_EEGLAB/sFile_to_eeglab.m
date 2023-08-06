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
    EEG.setname = 'Somethin';
    EEG.filename = sFile.FileName;
    EEG.filepath = fileparts(sFile.FileName);
    EEG.subject = sFile.SubjectName;
    EEG.group = [];
    EEG.condition = sFile.Condition;
    EEG.session = [];
    EEG.comments = sFile.Comment;
    EEG.trials = 1;
    EEG.pnts = study.F.header.nsamples;
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