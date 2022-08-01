function extension = GetExtensionFromDatasetFileFormat(fileFormat)
           
    switch lower(fileFormat)

        case 'brainvision'
            extension = '.eeg';

        case 'edf'
            extension = '.edf';

        otherwise
            error('Unsupported File Format');

    end

end