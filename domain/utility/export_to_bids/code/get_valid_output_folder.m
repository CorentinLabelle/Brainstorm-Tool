function validOutputFolder = get_valid_output_folder(outputFolder)
    if endsWith(outputFolder, filesep)
        outputFolder = outputFolder(1:end-1);
    end

    temporary_output_folder = outputFolder;
    index = 0;
    while isfolder(temporary_output_folder)
        temporary_output_folder = [outputFolder '_' num2str(index)];
        index = index + 1;
    end       
    validOutputFolder = [temporary_output_folder filesep];
end