function create_provenance_file(sFile, path)
    provenance_var = create_provenance_var(sFile);
    save_file(path, provenance_var);
end

function provenance = create_provenance_var(sFile)
    study_mat = load(sFile_get_study_path(sFile));

    for iHistory = 1:height(study_mat.History)
        activity = struct();
        activity.id = study_mat.History{iHistory,2};
        activity.label = study_mat.History{iHistory,3};
        activity.command = 'button pushed';
        activity.startedAtTime = study_mat.History{iHistory,1}; 

        provenance.(strcat('ActivityNo', num2str(iHistory))) = activity; 
    end       
end

