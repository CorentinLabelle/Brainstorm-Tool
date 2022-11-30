function reviewRawFiles = ReviewRawFiles(subjects, rawFiles)

    arguments
        subjects cell = {'subject01'};
        rawFiles cell = {...
            'folder/subFolder/dataset1.eeg', ...
            'folder/subFolder/dataset2.eeg'
            };
    end
    
    reviewRawFiles = Process.create('review raw files');
    reviewRawFiles.setParameter('subjects', subjects);
    reviewRawFiles.setParameter('raw files', {rawFiles});