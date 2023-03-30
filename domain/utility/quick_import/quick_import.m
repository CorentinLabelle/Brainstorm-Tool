function [subjects, rawFiles] = quick_import(folderToImport, extension)
    arguments
        folderToImport char = [];
        extension char = '.eeg';
    end
    
    assert(isfolder(folderToImport), 'The folder does not exist!')
   
    contentOfFolder = dir(folderToImport);
    foldersToSkip = [".", ".."];
    
    nbSubject = length(contentOfFolder) - length(foldersToSkip);
    subjects = cell(1, nbSubject);
    rawFiles = cell(1, nbSubject);
    index = 0;
    for i = 1:length(contentOfFolder)
        
        subFolder = contentOfFolder(i).name;

        if any(strcmp(subFolder, foldersToSkip))
           continue 
        end
        index = index + 1;

        file = dir(fullfile(folderToImport, subFolder, strcat('*', extension)));

        subjects{index} = subFolder;
        rawFiles{index} = fullfile({file.folder}, {file.name});

    end
end