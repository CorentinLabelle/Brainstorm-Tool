%%
clear
clc
addpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3');

%% Import Pipeline .mat

[fileName, folderPath] = uigetfile('*.mat', 'Select MAT file');

load(strcat(folderPath, fileName));

processes = Pipeline.Processes;

sensorType = Pipeline.Type;


%% sfile
sFiles = {'Frodo/@rawP8_B1/data_0raw_P8_B1.mat'};

%% Add EEG Position

if(isfield(processes,'AddEEGPosition'))
    
    capNumber = processes.AddEEGPosition.Parameters.CapNumber;  
    
    % Process: Add EEG positions
       bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
            'channelfile', {'', ''}, ...
            'usedefault',  1, ...
            'fixunits',    1, ...
            'vox2ras',     1);
end

%% Refine Registration
if(isfield(processes,'RefineRegistration'))
    
    % Process: Refine registration
    bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
    
end

%% Project Electrode on Scalp
if(isfield(processes,'ProjectElectrodeOnScalp'))
    
    % Process: Project electrodes on scalp
    bst_process('CallProcess', 'process_channel_project', sFiles, []);
    
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
    
    if sensorType == "EEG"
        win_length = 10;
    elseif app.AnalysisType == "MEG"
        win_length = 4;
    end
    
    bst_process('CallProcess', 'process_psd', sFiles, [], ...
                'timewindow',  [], ...
                'win_length',  win_length, ...
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

%% ICA

if(isfield(processes,'ICA'))
    
    nbComponents = processes.ICA.NumberOfComponents;
    
    bst_process('CallProcess', 'process_ica', sFiles, [], ...
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
            
end

for i = 1:length(sFiles)
    view_timeseries(sFiles(i).FileName);
    panel_ssp_selection('OpenRaw');
    waitfor(msgbox("Click when you are done choosing"));
end
