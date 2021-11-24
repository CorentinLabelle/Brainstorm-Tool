function cFiles = MEG_Pipeline(sFiles, processes)
% The argument sFiles is actually a cFiles

%% Add Path
addpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3');

%% Initialisation of variables
sensorType = 'MEG';

%% Import Pipeline .mat
% If function called with no processes structure, ask to import pipeline
% (.mat)

%assert(empty(sFiles), 'Vous devez sélectionner des études!');

if ~exist('processes','var')

    [fileName, folderPath] = uigetfile('*.mat', 'Select MAT file');
    
    if (fileName == 0)
        return
    end
        
    pipLoad = load(strcat(folderPath, fileName));

    processes = pipLoad.Processes;
        
end

%% Convert Epoch To Continue

if(isfield(processes,'ConvertEpochToContinue'))
    
    sFiles = bst_process('CallProcess', 'process_ctf_convert', sFiles, [], ...
                    'rectype', 2);
end

%% Notch Filter
    
if(isfield(processes,'NotchFilter'))

    frequence = processes.NotchFilter.Parameters;
    

    sFiles = bst_process('CallProcess', 'process_notch', sFiles, [], ...
                    'sensortypes', sensorType, ...
                    'freqlist',    frequence, ...
                    'cutoffW',     1, ...
                    'useold',      0, ...
                    'read_all',    0);

end

%% Band Pass Filter

if(isfield(processes,'BandPassFilter'))
    
    param = processes.BandPassFilter.Parameters;

    
    sFiles = bst_process('CallProcess', 'process_bandpass', sFiles, [], ...
                'sensortypes', sensorType, ...
                'highpass',    param(1), ...
                'lowpass',     param(2), ...    % il faut inverse le High and Low ... ?
                'tranband',    0, ...
                'attenuation', 'strict', ...  % 60dB
                'ver',         '2019', ...  % 2019
                'mirror',      0, ...
                'read_all',    0);
end

%% Power Spectrum Density

if(isfield(processes,'PowerSpectrumDensity'))
    
    winLength = processes.PowerSpectrumDensity.WindowLength;
    
    bst_process('CallProcess', 'process_psd', sFiles, [], ...
                'timewindow',  [], ...
                'win_length',  winLength, ...
                'win_overlap', 50, ...
                'clusters',    {}, ...
                'sensortypes', sensorType, ...
                'edit', struct(...
                'Comment',    'Power', ...
                'TimeBands',  [], ...
                'Freqs',      [], ...
                'ClusterFuncTime', 'none', ...
                'Measure',    'power', ...
                'Output',     'all', ...
                'SaveKernel', 0));
            
end

%% Detect Artifact

if(isfield(processes, 'DetectArtifact'))
    
    if(isfield(processes.DetectArtifact, 'Cardiac'))
        
        channelName = processes.DetectArtifact.Cardiac.Channel;
        eventName = processes.DetectArtifact.Cardiac.EventName;
        
        sFiles = bst_process('CallProcess', 'process_evt_detect_ecg', sFiles, [], ...
                            'channelname', channelName, ...
                            'timewindow',  [], ...
                            'eventname',   eventName);
    end
    
    
    if(isfield(processes.DetectArtifact, 'Blink'))
        
        channelName = processes.DetectArtifact.Blink.Channel;
        eventName = processes.DetectArtifact.Blink.EventName;
        
        sFiles = bst_process('CallProcess', 'process_evt_detect_eog', sFiles, [], ...
                            'channelname', channelName, ...
                            'timewindow',  [], ...
                            'eventname',   eventName);
    end
    
    
    
    if(isfield(processes.DetectArtifact, 'Other'))
        
        LowFreq = 0;
        if(isfield(processes.DetectArtifact.Other, 'LowFrequence'))
            LowFreq = processes.DetectArtifact.Other.LowFrequence;
        end
        
        HighFreq = 0;
        if(isfield(processes.DetectArtifact.Other, 'HighFrequence'))
            HighFreq = processes.DetectArtifact.Other.HighFrequence;
        end
        
        sFiles = bst_process('CallProcess', 'process_evt_detect_badsegment', sFiles, [], ...
                    'timewindow',  [], ...
                    'sensortypes', sensorType, ...
                    'threshold',   3, ...
                    'isLowFreq',   LowFreq, ...   % 0 ou 1: detect eyes/teeth movements
                    'isHighFreq',  HighFreq);      % 0 ou 1: detect muscular/sensor artifacts

    end
end

%% Remove Simultaneous Events

if(isfield(processes,'RemoveSimultaneousEvents'))
    
    remove = processes.RemoveSimultaneousEvents.EventToRemove;
    target = processes.RemoveSimultaneousEvents.TargetEvent;

    % Remove Simultaneaous Events
    bst_process('CallProcess', 'process_evt_remove_simult', sFiles, [], ...
        'remove', remove, ...
        'target', target, ...
        'dt',     0.25, ...
        'rename', 0);
                
end

%% SSP

if(isfield(processes,'SSP'))

    if(isfield(processes.SSP, 'Cardiac'))
        
        eventName = processes.SSP.Cardiac.EventName;
    
        sFiles = bst_process('CallProcess', 'process_ssp_ecg', sFiles, [], ...
                    'eventname',   eventName, ...
                    'sensortypes', sensorType, ...
                    'usessp',      1, ...
                    'select',      1);
    end
    
    if(isfield(processes.SSP, 'Blink'))
        
        eventName = processes.SSP.Blink.EventName;
    
        sFiles = bst_process('CallProcess', 'process_ssp_eog', sFiles, [], ...
                    'eventname',   eventName, ...
                    'sensortypes', sensorType, ...
                    'usessp',      1, ...
                    'select',      1);
    end
    
    if(isfield(processes.SSP, 'Generic'))
        
        eventName = processes.SSP.Generic.EventName;
    
        sFiles = bst_process('CallProcess', 'process_ssp', sFiles, [], ...
            'timewindow',  [], ...
            'eventname',   eventName, ...
            'eventtime',   [-0.2, 0.2], ...
            'bandpass',    [1.5, 15], ...
            'sensortypes', '', ...
            'usessp',      1, ...
            'saveerp',     0, ...
            'method',      1, ...  % PCA: One component per sensor
            'select',      1);

    end

    for i = 1:length(sFiles)
        view_timeseries(sFiles(i).FileName);
        panel_ssp_selection('OpenRaw');
        waitfor(errordlg("Click when you are done choosing"));
    end
end

%% ICA

if(isfield(processes,'ICA'))
    
    nbComponents = processes.ICA.NumberOfComponents;
    
    sFiles = bst_process('CallProcess', 'process_ica', sFiles, [], ...
                'timewindow', [], ...
                'eventname', '', ...
                'eventtime', [0, 0], ...
                'bandpass', [0, 0], ...
                'nicacomp', nbComponents, ... % modifi ici!
                'sensortypes', sensorType, ...
                'icasort',      '', ...
                'usessp', 1, ...
                'ignorebad', 1, ...
                'saveerp', 0, ...
                'method', 1, ...
                'select', []);
    
    for i = 1:length(sFiles)
        view_timeseries(sFiles(i).FileName);
        panel_ssp_selection('OpenRaw');
        waitfor(msgbox("Click when you are done choosing. It will skip to the next study."));
    end

end

%% Conversion to BIDS
if (isfield(process,'ConvertToBIDS'))
    
    if (isfield(process.ConvertToBIDS, 'cFile'))
        sFiles = process.ConvertToBIDS.cFile;
    end
    
    BIDSpath = process.ConvertToBIDS.BIDSpath;
    
    bst_process('CallProcess', 'process_export_bids', sFiles, [], ...
         'bidsdir',       {BIDSpath, 'BIDS'}, ...
         'subscheme',     2, ...  % Number index
         'sesscheme',     1, ...  % Acquisition date
         'emptyroom',     'emptyroom, noise', ...
         'defacemri',     0, ...
         'overwrite',     0, ...
         'powerline',     2, ...  % 60 Hz
         'dewarposition', 'Upright', ...
         'eegreference',  'Cz', ...
         'edit',          struct(...
         'ProjName',    [], ...
         'ProjID',      [], ...
         'ProjDesc',    [], ...
         'Categories',  [], ...
         'JsonDataset', ['{' 10 '  "License": "PD"' 10 '}'], ...
         'JsonMeg',     ['{' 10 '  "TaskDescription": "My task"' 10 '}']));

end

%% Return cFile
    
    if class(sFiles) ~= "cell"
        cFiles = cell(1, length(sFiles));
        for i = 1:length(sFiles)
            cFiles{i} = sFiles(i).FileName;
        end
    end
    
    return

end

