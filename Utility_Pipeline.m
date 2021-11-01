function cFiles = Utility_Pipeline(process, sFiles)
%%
addpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3');

if ~exist('sFiles','var')

    sFiles = [];
    
end

%% Import Anatomy

if(isfield(process,'ImportAnatomy'))
    
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

if(isfield(process,'ReviewRawFiles'))

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



%% Convert to BIDS

if(isfield(process,'ConvertToBIDS'))
    
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

