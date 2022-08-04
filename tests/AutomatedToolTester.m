classdef AutomatedToolTester < matlab.uitest.TestCase
    
    properties (Constant, Access = private)
       
        ProtocolName = 'Protocol_AutoToolTester';
        
    end
    
    methods(TestMethodSetup)
        
    end
    
    methods(TestMethodTeardown)   
        
    end
    
    methods (Test)
        
        function testWithValidAnalysisFile(~)
           
            path = CreateAnalysisFile();
            automatedTool = AutomatedTool();
            sFilesOut = automatedTool.run(path);
            
        end
        
        function testNewProtocolWithoutCreatingNewSubject(tc)
           
            path = tc.createAnalysisFileWithNewProtocolWithoutCreatingNewSubject();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
        function testWithNoInput(tc)
           
            automatedTool = AutomatedTool();            
            tc.verifyError(@() automatedTool.run(string.empty()), ?MException);
            
        end
        
        function testWithWrongExtension(tc)
           
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(fullfile(pwd, 'allo.mat')), ?MException);
            
        end
        
        function testWithNoProtocol(tc)
            
            path = tc.createAnalysisFileWithWithoutProtocol();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
        function testWithNoPipeline(tc)
            
            path = tc.createAnalysisFileWithWithoutPipeline();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
        function testWithNoSFileAndNoReviewRawFiles(tc)
            
            path = tc.createAnalysisFileWithoutSFileAndWithReviewRawFiles();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
    end
    
    methods (Access = public)
        
        function pipeline = createPipelineForTest(~)
           
            filePath = mfilename('fullpath');
            [fileFolder, fileName] = fileparts(filePath);

            pipeline = Pipeline();
            pipeline.setName(fileName);
            pipeline.setFolder(fileFolder);
            pipeline.setExtension(Pipeline.getSupportedExtension);

            pipeline.addProcess(CreateSubject());
            pipeline.addProcess(ReviewRawFiles());
            pipeline.addProcess(AddEegPosition());
            pipeline.addProcess(RefineRegistration());
            pipeline.addProcess(ProjectElectrodeOnScalp());
            pipeline.addProcess(NotchFilter());
            pipeline.addProcess(BandPassFilter());
            pipeline.addProcess(PowerSpectrumDensity());
            
        end
        
        function path = createAnalysisFileWithNewProtocolWithoutCreatingNewSubject(tc)
            
           jsonStructure = struct();
           jsonStructure.Protocol = 'This must be a new protocol';
           jsonStructure.sFile = [];
           
           pipeline = tc.createPipelineForTest();
           pipeline.deleteProcess(pipeline.getProcessIndexWithName('create subject'));
           jsonStructure.Pipeline = pipeline;
           
           path = tc.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithWithoutProtocol(tc)
            
           jsonStructure = struct();
           jsonStructure.sFile = [];
           jsonStructure.Pipeline = tc.createPipelineForTest();
           
           path = tc.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithWithoutPipeline(tc)
            
           jsonStructure = struct();
           jsonStructure.sFile = [];
           jsonStructure.Protocol = tc.ProtocolName;
           
           path = tc.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithoutSFileAndWithReviewRawFiles(tc)
           
           jsonStructure = struct();
           jsonStructure.Protocol = tc.ProtocolName;
           jsonStructure.sFile = [];
           
           pipeline = tc.createPipelineForTest();
           pipeline.deleteProcess(pipeline.getProcessIndexWithName('review raw files'));
           jsonStructure.Pipeline = pipeline;
           
           path = tc.saveJsonStructure(jsonStructure);
            
        end
        
        function path = saveJsonStructure(~, jsonStructure)
           
            path = [mfilename('fullpath') '.json'];
            FileSaver.save(path, jsonStructure);
            
        end
        
    end
    
end