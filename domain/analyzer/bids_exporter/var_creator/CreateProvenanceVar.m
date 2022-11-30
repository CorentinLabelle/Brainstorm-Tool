function provenance = CreateProvenanceVar(sFile)

    % Load study.mat file
    studyMat = load(SFileManager.getStudyPathFromSFile(sFile));
    %studyMat = load(fullfile(BstUtility.getDatabasePath(), bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));

    % Loop through every event
    for j = 1:height(studyMat.History)
        activity = struct();
        activity.id = studyMat.History{j,2};
        activity.label = studyMat.History{j,3};
        activity.command = 'button pushed';
        activity.startedAtTime = studyMat.History{j,1}; 

        provenance.(strcat('ActivityNo', num2str(j))) = activity; 
    end
            
end

