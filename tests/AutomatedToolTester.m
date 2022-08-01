classdef AutomatedToolTester < matlab.uitest.TestCase
    
    properties (Constant, Access = private)
       
        ProtocolName = 'Protocol_AutoToolTester';
        
    end
    
    methods(TestMethodSetup)
        
    end
    
    methods(TestMethodTeardown)   
        
    end
    
    methods (Test)
        
        function testWithValidAnalysisFile(tc)
           
            path = AutomatedToolTester.createValidAnalysisFile();
            automatedTool = AutomatedTool();
            sFilesOut = automatedTool.run(path);
            
        end
        
        function testNewProtocolWithoutCreatingNewSubject(tc)
           
            path = AutomatedToolTester.createValidAnalysisFileWithNewProtocolWithoutCreatingNewSubject();
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
            
            path = AutomatedToolTester.createAnalysisFileWithWithoutProtocol();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
        function testWithNoPipeline(tc)
            
            path = AutomatedToolTester.createAnalysisFileWithWithoutPipeline();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
        function testWithNoSFileAndNoReviewRawFiles(tc)
            
            path = AutomatedToolTester.createAnalysisFileWithoutSFileAndWithReviewRawFiles();
            automatedTool = AutomatedTool();
            tc.verifyError(@() automatedTool.run(path), ?MException);
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function pipeline = createPipelineForTest()
           
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
        
        function path = createValidAnalysisFile()
            
            jsonStructure = struct();
            jsonStructure.Protocol = tc.ProtocolName;
            jsonStructure.sFile = [];
            jsonStructure.Pipeline = AutomatedToolTester.createPipelineForTest();

            path = AutomatedToolTester.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithNewProtocolWithoutCreatingNewSubject()
            
           jsonStructure = struct();
           jsonStructure.Protocol = tc.ProtocolName;
           jsonStructure.sFile = [];
           
           pipeline = AutomatedToolTester.createPipelineForTest();
           pipeline.deleteProcess(pipeline.getProcessIndexWithName('create subject'));
           jsonStructure.Pipeline = pipeline;
           
           path = AutomatedToolTester.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithWithoutProtocol()
            
           jsonStructure = struct();
           jsonStructure.sFile = [];
            jsonStructure.Pipeline = AutomatedToolTester.createPipelineForTest();
           
           path = AutomatedToolTester.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithWithoutPipeline()
            
           jsonStructure = struct();
           jsonStructure.sFile = [];
           jsonStructure.Protocol = tc.ProtocolName;
           
           path = AutomatedToolTester.saveJsonStructure(jsonStructure);
            
        end
        
        function path = createAnalysisFileWithoutSFileAndWithReviewRawFiles()
           
           jsonStructure = struct();
           jsonStructure.Protocol = tc.ProtocolName;
           jsonStructure.sFile = [];
           
           pipeline = AutomatedToolTester.createPipelineForTest();
           pipeline.deleteProcess(pipeline.getProcessIndexWithName('review raw files'));
           jsonStructure.Pipeline = pipeline;
           
           path = AutomatedToolTester.saveJsonStructure(jsonStructure);
            
        end
        
        function path = saveJsonStructure(jsonStructure)
           
            path = [mfilename('fullpath') '.json'];
            FileSaver.save(path, jsonStructure);
            
        end
        
    end
    
end