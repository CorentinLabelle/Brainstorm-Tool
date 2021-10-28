function cFiles = MEG_Pipeline(sFiles, processes)
%%
addpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3');

%% Import Pipeline .mat

if ~exist('processes','var')

    [fileName, folderPath] = uigetfile('*.mat', 'Select MAT file');

    pipLoad = load(strcat(folderPath, fileName));

    processes = pipLoad.Processes;

    sensorType = 'MEG';
end


%% sfile
%sFiles = {'Frodo/@rawP8_B1/data_0raw_P8_B1.mat'};


%% Convert Epoch To Continue

if(isfield(processes,'ConvertEpochToContinue'))
    
    bst_process('CallProcess', 'process_ctf_convert', sFiles, [], ...
                    'rectype', 2);
end

%% Detect Artifact

if(isfield(processes, 'DetectArtifact'))
    
    if(isfield(processes.DetectArtifact, 'Cardiac'))
        
        channelName = processes.DetectArtifact.Channel;
        eventName = processes.DetectArtifact.EventName;
        
        bst_process('CallProcess', 'process_evt_detect_ecg', sFiles, [], ...
            'channelname', channelName, ...
            'timewindow',  [], ...
            'eventname',   eventName);
    end
    
    
    if(isfield(processes.DetectArtifact, 'Blink'))
        
        channelName = processes.DetectArtifact.Channel;
        eventName = processes.DetectArtifact.EventName;
        
        bst_process('CallProcess', 'process_evt_detect_eog', sFiles, [], ...
            'channelname', channelName, ...
            'timewindow',  [], ...
            'eventname',   eventName);
    end
    
    
    
    if(isfield(processes.DetectArtifact, 'Other'))
        
        LowFreq = processes.DetectArtifact.LowFrequence;
        HighFreq = processes.DetectArtifact.HighFrequence;
        
        bst_process('CallProcess', 'process_evt_detect_badsegment', sFiles, [], ...
                    'timewindow',  [], ...
                    'sensortypes', sensorType, ...
                    'threshold',   3, ...
                    'isLowFreq',   LowFreq, ...   % 0 ou 1: detect eyes/teeth movements
                    'isHighFreq',  HighFreq);      % 0 ou 1: detect muscular/sensor artifacts

    end
end

%% Return cFile
if exist('sFiles','var')
    cFiles = sFiles.FileName;
else
    cFiles = [];
end   
return

end

