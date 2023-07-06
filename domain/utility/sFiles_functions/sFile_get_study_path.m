function path = sFile_get_study_path(sFile)
    database_directory = bst_get('BrainstormDbDir');
    path = fullfile(database_directory, bst_get('ProtocolInfo').Comment, 'data', sFile.FileName);
end