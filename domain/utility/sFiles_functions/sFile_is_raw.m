function isRaw = sFile_is_raw(sFile)            
    study_file = load(sFile_get_study_path(sFile));
    isRaw = true;
    if strcmp(study_file.F.format, 'BST-BIN')
        isRaw = false;
    end            
end