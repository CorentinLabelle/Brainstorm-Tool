function cFiles = EEG_Pipeline(sFiles, processes)
% The argument sFiles is actually a cFiles

%% Add Path
addpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3');

%% Initialisation of variables
sensorType = 'EEG';

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
%% sfile
%sFiles = {'Frodo/@rawP8_B1/data_0raw_P8_B1.mat'};

%% Add EEG Position

if(isfield(processes,'AddEEGPosition'))
    
    if processes.AddEEGPosition.FileType == "Use Default Pattern"
        capNumber = processes.AddEEGPosition.CapNumber;  

        % Process: Add EEG positions
      sFiles =  bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
                'channelfile', {'', ''}, ...
                'usedefault',  capNumber, ...
                'fixunits',    1, ...
                'vox2ras',     1);
            
    elseif processes.AddEEGPosition.FileType == "Import"
        
        bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
                                'channelfile', {file, 'XENSOR'}, ...
                                'usedefault', 1, ...
                                'fixunits', 1, ...
                                'vox2ras', 0);
    end                     
end

%% Refine Registration

if(isfield(processes,'RefineRegistration'))
    
    % Process: Refine registration
    sFiles = bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
    
end

%% Project Electrode on Scalp
if(isfield(processes,'ProjectElectrodeOnScalp'))
    
    % Process: Project electrodes on scalp
    sFiles = bst_process('CallProcess', 'process_channel_project', sFiles, []);
    
end

%% Detect Heartbeats

if(isfield(processes, 'DetectArtifact'))
    
    if(isfield(processes.DetectArtifact, 'Cardiac'))
        
        channelName = processes.DetectArtifact.Cardiac.Channel;
        eventName = processes.DetectArtifact.Cardiac.EventName;
        
        sFiles = bst_process('CallProcess', 'process_evt_detect_ecg', sFiles, [], ...
                            'channelname', channelName, ...
                            'timewindow',  [], ...
                            'eventname',   eventName);
    end
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


%% Average Reference

if(isfield(processes,'AverageReference'))
    
    bst_process('CallProcess', 'process_eegref', sFiles, [], ...
             'eegref', 'AVERAGE', ...
             'sensortypes', sensorType);

    for i = 1:length(sFiles)
         view_timeseries(sFiles{i});
         panel_ssp_selection('OpenRaw');
         waitfor(errordlg("Click when you are done choosing"));
    end
 
end
 
%% ICA

if(isfield(processes,'ICA'))
    
    nbComponents = processes.ICA.NumberOfComponents;
    
    %message = uiconfirm(app.UIFigure, ...
        %'This might take a couple a minutes... You have time ti grab a cup of coffee.', 'loading');

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
            

    %delete(message);
    
        for i = 1:length(sFiles)
            view_timeseries(sFiles(i).FileName);
            panel_ssp_selection('OpenRaw');
            waitfor(msgbox("Click when you are done choosing. It will skip to the next study."));
        end

end




%% Return cFile

    if class(sFiles) ~= "cell"
        cFiles = cell(1, length(sFiles));
        for i = 1:length(sFiles)
            cFiles{i} = sFiles(i).FileName;
        end
    end
    
     msg = msgbox('Opération Terminée', 'Opération Terminée');
     pause(2)
     delete(msg);
     
    return

end