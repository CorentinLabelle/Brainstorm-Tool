function eegPipeline = CreateEegPipeline()

    filePath = mfilename('fullpath');
    [fileFolder, fileName] = fileparts(filePath);
    
    eegPipeline = Pipeline();
    eegPipeline.setName(fileName);
    eegPipeline.setFolder(fileFolder);
    eegPipeline.setExtension(Pipeline.getSupportedExtension);
    
    eegPipeline.addProcess(CreateSubject());
    eegPipeline.addProcess(ReviewRawFiles());
    eegPipeline.addProcess(AddEegPosition());
    eegPipeline.addProcess(RefineRegistration());
    eegPipeline.addProcess(ProjectElectrodeOnScalp());
    eegPipeline.addProcess(NotchFilter());
    eegPipeline.addProcess(BandPassFilter());
    eegPipeline.addProcess(PowerSpectrumDensity());
    eegPipeline.addProcess(Ica());
    eegPipeline.addProcess(AverageReference());
    eegPipeline.addProcess(ExportToBids());