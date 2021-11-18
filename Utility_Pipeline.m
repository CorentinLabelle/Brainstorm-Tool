function cFiles = Utility_Pipeline(process, sFiles)
%%
addpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3');

if ~exist('sFiles','var')

    sFiles = [];
    
end

%% Start a new report
% bst_report('Start', sFiles);

%% Import Anatomy

if (isfield(process,'ImportAnatomy'))
    
    subjectName = process.ImportAnatomy.SubjectName;
    anatomyPath = process.ImportAnatomy.AnatomyPath;
    analysisType = process.ImportAnatomy.AnalysisType;
    anatomyFileFormat = process.ImportAnatomy.AnatomyFileFormat;

    if analysisType == "MEG"

        bst_process('CallProcess', 'process_import_anatomy', [], [], ...
            'subjectname', subjectName, ...
            'mrifile', {anatomyPath, anatomyFileFormat}, ...
            'nvertices', 15000, ...
            'nas', [127, 213, 139], ...
            'lpa', [52, 113, 96], ...
            'rpa', [202, 113, 91], ...
            'ac', [127 119 149], ...
            'pc', [128 93 141], ...
            'ih', [131 114 206]);

    elseif analysisType == "EEG"

        bst_process('CallProcess', 'process_import_anatomy', [], [], ...
            'subjectname', subjectName, ...
            'mrifile', {anatomyPath, anatomyFileFormat}, ...
            'nvertices', 15000);
    end
      
end

%% Review Raw Files

if (isfield(process,'ReviewRawFiles'))

    ChannelAlign = process.ReviewRawFiles.ChannelAlign;
    SubjectName = process.ReviewRawFiles.SubjectName;
    RawFilePath = process.ReviewRawFiles.RawFilesPath;
    FileFormat = process.ReviewRawFiles.FileFormat;
    
    sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
        'subjectname',  SubjectName, ...
        'datafile',     {RawFilePath, FileFormat}, ...
        'channelreplace', 1, ...
        'channelalign', ChannelAlign, ... % Align channel on MRI using fiducial points
        'evtmode',     'value');
                                
end

%% Select Files (select only good trial from an imported study).

if (isfield(process,'SelectFiles'))
    
    subjectName = process.SelectFiles.SubjectName;
    condition = process.SelectFiles.Condition;

    sFiles = bst_process('CallProcess', 'process_select_files_data', sFiles, [], ...
        'subjectname',   subjectName, ...
        'condition',     condition, ...
        'tag',           '', ...    Select file that include the tag
        'includebad',    0, ...     1/0
        'includeintra',  0, ...     1/0
        'includecommon', 0);        %1/0
    
end

%% Convert to BIDS

if (isfield(process,'ConvertToBIDS'))
    
    cFiles = process.ConvertToBIDS.cFile;
    BIDSpath = process.ConvertToBIDS.BIDSpath;
    
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


%% Import Events

if (isfield(process,'ImportEvent'))
    
    subjectName = process.ImportEvent.SubjectName;
    event = process.ImportEvent.Event;
    epochTime = process.ImportEvent.EpochTime;
    
    sFiles = bst_process('CallProcess', 'process_import_data_event', sFiles, [], ...
    'subjectname', subjectName, ...
    'condition',   '', ...
    'eventname',   event, ...
    'timewindow',  [], ...
    'epochtime',   epochTime, ...
    'createcond',  1, ...
     'ignoreshort', 1, ...
     'usectfcomp',  1, ...
     'usessp',      1, ...
     'freq',        [], ...
     'baseline',    []);

end


%% Reject Bad Trials (Peak to Peak)

if (isfield(process, 'RejectTrial'))
    
    
    megGrad = [];
    megMagneto = [];
    eeg = [];
    seeg_ecog = [];
    eog = [];
    ecg = [];
    
    if (isfield(process.RejectTrial, 'MEGgrad'))
        megGrad = process.RejectTrial.MEGgrad;

    elseif (isfield(process.RejectTrial, 'MEGmagneto'))
        megMagneto = process.RejectTrial.MEGmagneto;
        
    elseif (isfield(process.RejectTrial, 'EEG'))
        eeg = process.RejectTrial.EEG;
        
    elseif (isfield(process.RejectTrial, 'SEEG_ECOG'))
        seeg_ecog = process.RejectTrial.SEEG_ECOG;
        
    elseif (isfield(process.RejectTrial, 'EOG'))
        eog = process.RejectTrial.EOG;
        
    elseif (isfield(process.RejectTrial, 'ECG'))
        ecg = process.RejectTrial.ECG;

    end
    

    sFiles = bst_process('CallProcess', 'process_detectbad', sFiles, [], ...
        'timewindow', [], ...
        'meggrad',    megGrad, ...
        'megmag',     megMagneto, ...
        'eeg',        eeg, ...
        'ieeg',       seeg_ecog, ...
        'eog',        eog, ...
        'ecg',        ecg, ...
        'rejectmode', 2);  % Reject the entire trial

end

%% Average

if isfield(process, 'Average')
    
    averageType = process.Average.AverageTypeNumber;
    averageFunction = process.Average.AverageFunctionNumber;

    sFiles = bst_process('CallProcess', 'process_average', sFiles, [], ...
        'avgtype',       averageType, ...  % By folder (grand average)
        'avg_func',      averageFunction, ...  % Average absolute values:  mean(abs(x))
        'weighted',      0, ...
        'keepevents',    0);

end

%% Save and display report
% ReportFile = bst_report('Save', sFiles);
% bst_report('Open', ReportFile);

%% Return cFile

     if class(sFiles) ~= "cell"
        cFiles = cell(1, length(sFiles));
        for i = 1:length(sFiles)
            cFiles{i} = sFiles(i).FileName;
        end
     end
     
    return

end

