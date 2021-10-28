function cFile = Utility_Processes(process)


%% Import Anatomy

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
            

%% Review Raw Files

if(isfield(process,'ReviewRawFiles'))

    ChannelAlign = process.ReviewRawFiles.ChannelAlign;
    SubjectName = process.ReviewRawFiles.SubjectName;
    RawFilePath = process.ReviewRawFiles.RawFilePath;
    FileFormat = process.ReviewRawFiles.FileFormat;
    
    sFiles = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
        'subjectname',  SubjectName, ...
        'datafile',     {RawFilePath, FileFormat}, ...
        'channelreplace', 1, ...
        'channelalign', ChannelAlign); % Align channel on MRI using fiducial points
end




cFile = sFiles.FileName;
return
end

