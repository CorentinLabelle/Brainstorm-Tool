function cFiles = EEG_Pipeline(cFiles, processes, app)
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

%% Add EEG Position

if(isfield(processes,'AddEEGPosition'))
    
    if processes.AddEEGPosition.FileType == "Use Default Pattern"
        capNumber = processes.AddEEGPosition.CapNumber;  

        % Process: Add EEG positions
      sFiles =  bst_process('CallProcess', 'process_channel_addloc', cFiles, [], ...
                'channelfile', {'', ''}, ...
                'usedefault',  capNumber, ...
                'fixunits',    1, ...
                'vox2ras',     1);
            
       cFiles = {sFiles.FileName};
            
    elseif processes.AddEEGPosition.FileType == "Import"
        
        bst_process('CallProcess', 'process_channel_addloc', cFiles, [], ...
                                'channelfile', {file, 'XENSOR'}, ...
                                'usedefault', 1, ...
                                'fixunits', 1, ...
                                'vox2ras', 0);
    end                     
end

%% Refine Registration

if(isfield(processes,'RefineRegistration'))
    
    % Process: Refine registration
    sFiles = bst_process('CallProcess', 'process_headpoints_refine', cFiles, []);
    
    cFiles = {sFiles.FileName};
    
end

%% Project Electrode on Scalp
if(isfield(processes,'ProjectElectrodeOnScalp'))
    
    % Process: Project electrodes on scalp
    sFiles = bst_process('CallProcess', 'process_channel_project', sFiles, []);
    
    cFiles = {sFiles.FileName};
end

%% Detect Heartbeats

if(isfield(processes, 'DetectArtifact'))
    
    if(isfield(processes.DetectArtifact, 'Cardiac'))
        
        channelName = processes.DetectArtifact.Cardiac.Channel;
        eventName = processes.DetectArtifact.Cardiac.EventName;
        
        sFiles = bst_process('CallProcess', 'process_evt_detect_ecg', cFiles, [], ...
                            'channelname', channelName, ...
                            'timewindow',  [], ...
                            'eventname',   eventName);
                        
        cFiles = {sFiles.FileName};
    end
end

%% Notch Filter
    
if(isfield(processes,'NotchFilter'))

    frequence = processes.NotchFilter.Parameters;
    
    date = app.getDateFromBrainstormStudyMAT(cFiles);

    sFiles = bst_process('CallProcess', 'process_notch', cFiles, [], ...
                    'sensortypes', sensorType, ...
                    'freqlist',    frequence, ...
                    'cutoffW',     1, ...
                    'useold',      0, ...
                    'read_all',    0);
    cFiles = {sFiles.FileName};

    app.modifyBrainstormStudyMATDate(cFiles, date);
end

%% Band Pass Filter

if(isfield(processes,'BandPassFilter'))
    
    param = processes.BandPassFilter.Parameters;

    date = app.getDateFromBrainstormStudyMAT(cFiles);
    
    sFiles = bst_process('CallProcess', 'process_bandpass', cFiles, [], ...
                'sensortypes', sensorType, ...
                'highpass',    param(1), ...
                'lowpass',     param(2), ...    % il faut inverse le High and Low ... ?
                'tranband',    0, ...
                'attenuation', 'strict', ...  % 60dB
                'ver',         '2019', ...  % 2019
                'mirror',      0, ...
                'read_all',    0);
            
    cFiles = {sFiles.FileName};
            
    app.modifyBrainstormStudyMATDate(cFiles, date);
end

%% Power Spectrum Density

if(isfield(processes,'PowerSpectrumDensity'))
    
    winLength = processes.PowerSpectrumDensity.WindowLength;
    
    bst_process('CallProcess', 'process_psd', cFiles, [], ...
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
    
    bst_process('CallProcess', 'process_eegref', cFiles, [], ...
             'eegref', 'AVERAGE', ...
             'sensortypes', sensorType);

    for i = 1:length(cFiles)
         view_timeseries(cFiles{i});
         panel_ssp_selection('OpenRaw');
         waitfor(errordlg("Click when you are done choosing"));
    end
 
end
 
%% ICA

if(isfield(processes,'ICA'))
    
    nbComponents = processes.ICA.NumberOfComponents;

    sFiles = bst_process('CallProcess', 'process_ica', cFiles, [], ...
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
            
    for i = 1:length(cFiles)
        view_timeseries(cFiles{i});
        panel_ssp_selection('OpenRaw');
        waitfor(msgbox("Click when you are done choosing. It will skip to the next study."));
    end

end

%% Conversion to BIDS

if (isfield(processes,'ConvertToBIDSz'))
    
    if (isfield(processes.ConvertToBIDS, 'cFile'))
        cFiles = processes.ConvertToBIDS.cFile;
    end
    
    if (class(sFiles) == "struct")
        cFiles = {sFiles.FileName};
    end
    
    BIDSpath = processes.ConvertToBIDS.BIDSpath;
    
    % Create folder
    mkdir(BIDSpath);
    
    bst_process('CallProcess', 'process_export_bids', cFiles, [], ...
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

%% Conversion to BIDS test

if (isfield(processes,'ConvertToBIDS'))

%     if (isfield(processes.ConvertToBIDS, 'cFile'))
%         cFiles = processes.ConvertToBIDS.cFile;
%     end
    
    BIDSpath = processes.ConvertToBIDS.BIDSpath;
    
    % Create folder
    mkdir(BIDSpath);
            
    for i = 1:length(cFiles)
                
        % Export all study to EDF
        edfFilePath = app.exportToEDF(cFiles(i), app.WorkingFolderPath);
        date = app.getDateFromBrainstormStudyMAT(cFiles(i));
        app.modifyEDFDate(edfFilePath, date);


        % Reimport EDF file in Brainstorm 
                % (it creates a new study that will later be deleted)
        [subjectName] = app.getFilesPathFromcFile(cFiles(i));

        structure = struct();
        structure.ReviewRawFiles.ToRun = true;
        structure.ReviewRawFiles.SubjectName = subjectName;
        structure.ReviewRawFiles.RawFilesPath = edfFilePath;
        structure.ReviewRawFiles.FileFormat = 'EEG-EDF';
        structure.ReviewRawFiles.ChannelAlign = 0;

        cFilesEDF = Utility_Pipeline(structure);


        % Modify date in new brainstormstudy.mat
        app.modifyBrainstormStudyMATDate(cFilesEDF, date)


        % Convert EDF study to BIDS
        bst_process('CallProcess', 'process_export_bids', cFilesEDF, [], ...
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

     
        % Get Path for TSV, JSON and PROVENANCE files.
        [TSVpath, JSONpath, PROVpath, ELECTRODEpath] = app.getBIDSpath(cFiles(i), BIDSpath);


        % Create .tsv file (Events)
        app.createTsvFile(cFiles(i), TSVpath);


        % Create Json event description file
        app.createJsonEventFile(cFiles(i), JSONpath);


        % Create provenance file
        app.createProvenanceFile(cFiles(i), PROVpath);


        % Create electrode file
        app.createTsvElectrodeFile(cFiles(i), ELECTRODEpath);


        % Update Tree and Check new Studies 
            % (Order is importantsince the 'review raw files' of EDF study 
            % will add a newstudy that we need to delete.
        app.updateTreeAndCheckNewStudies;
        bst_process('CallProcess', 'process_delete', cFilesEDF, [], ...
        'target', 2); % 1: fichier 2: folder 3: subjects

    end

    app.updateTree;
            
end

%% Update Tree

app.updateTreeAndCheckNewStudies;

%% Return cFile

%     if class(sFiles) ~= "cell"
%         cFiles = {sFiles.FileName};
%     end
     
    return

end