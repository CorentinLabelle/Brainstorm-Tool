function path = sFile_get_subject_file_path(sFile)            
    channelFile = string({sFile.SubjectFile});
    path = fullfile(bst_get('BrainstormDbDir'), ...
            bst_get('ProtocolInfo').Comment, ...
            'anat', channelFile);        
end