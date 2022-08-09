function filepath = CreateAnalysisFileOutputTemplate(filename)
    arguments
        filename = 'AnalysisFileTemplate_output.json';
    end
    
    emptySFile = getEmptySFile();
    filepath = fullfile(PathsGetter.getAutomatedToolFolder(), filename);
    FileSaver.save(filepath, emptySFile);
    
end

function emptySFile = getEmptySFile()

    emptySFile.iStudy = double.empty();
    emptySFile.iItem = double.empty();
    emptySFile.FileName = string.empty();
    emptySFile.FileType = string.empty();
    emptySFile.Comment = string.empty();
    emptySFile.Condition = string.empty();
    emptySFile.SubjectFile = string.empty();
    emptySFile.SubjectName = string.empty();
    emptySFile.DataFile = string.empty();
    emptySFile.ChannelFile = string.empty();
    emptySFile.ChannelTypes = string.empty();

end