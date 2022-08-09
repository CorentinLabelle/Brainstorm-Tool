function templatePipeline = CreateTemplatePipeline()
    
    templatePipeline = Pipeline();
    templatePipeline.setName('PipelineName');
    templatePipeline.setFolder('SomeFolder');
    templatePipeline.setExtension(Pipeline.getSupportedExtension);
    
    templatePipeline.addProcess(CreateSubject());
    templatePipeline.addProcess(ReviewRawFiles());
    templatePipeline.addProcess(AddEegPosition());
    templatePipeline.addProcess(RefineRegistration());
    templatePipeline.addProcess(ProjectElectrodeOnScalp());
    templatePipeline.addProcess(NotchFilter());
    templatePipeline.addProcess(BandPassFilter());
    templatePipeline.addProcess(PowerSpectrumDensity());
    templatePipeline.addProcess(Ica());
    templatePipeline.addProcess(AverageReference());
    templatePipeline.addProcess(ExportToBids());