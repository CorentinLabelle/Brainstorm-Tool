classdef PipelineTester < matlab.unittest.TestCase

    methods(TestMethodSetup)
        
    end
    
    methods(TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function emptyConstructor(tc)

            pipTest = Pipeline();
              
            tc.verifyEqual(pipTest.Name, "", 'Name');
            tc.verifyEqual(pipTest.Folder, "", 'Folder');
            tc.verifyEqual(pipTest.Extension, string.empty, 'Extension');
            tc.verifyEqual(pipTest.Processes, cell.empty(), 'Process');
            tc.verifyEqual(pipTest.Documentation, char.empty, 'Doc');
            
        end
        
        function constructorWithValidStructure(tc)
           
            structTest = PipelineTester.generateTestStructure;
            
            pipTest = Pipeline(structTest);
            
            tc.verifyEqual(pipTest.Name, "Pipeline_Construct_With_Structure", 'Name');
            tc.verifyEqual(pipTest.Folder, "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool", 'Folder');
            tc.verifyEqual(pipTest.Extension, ".json", 'Extension');
            tc.verifyEqual(pipTest.Processes, structTest.Processes, 'Process');
            tc.verifyEqual(pipTest.Documentation, 'I''ve been construct with a structure', 'Doc');

        end
        
        function constructorWithInvalideStructureAdditionnalField(tc)
           
            structTest = PipelineTester.generateTestStructure;
            
            structTest.UnknownField = 'Unknown Field Value';
            structTest.AdditionnalField = 1;
            
            pipTest = Pipeline(structTest);
                            
            tc.verifyEqual(pipTest.Name, "Pipeline_Construct_With_Structure", 'Name');
            tc.verifyEqual(pipTest.Folder, "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool", 'Folder');
            tc.verifyEqual(pipTest.Extension, ".json", 'Extension');
            tc.verifyEqual(pipTest.Processes, structTest.Processes, 'Process');
            tc.verifyEqual(pipTest.Documentation, 'I''ve been construct with a structure', 'Doc');

            
        end
        
        function constructorWithValidName(tc)
            
            name = 'Constructor with name';
            pipTest = Pipeline(name);
                            
            tc.verifyEqual(pipTest.Name, "Constructor with name", 'Name');
            tc.verifyEqual(pipTest.Folder, "", 'Folder');
            tc.verifyEqual(pipTest.Extension, string.empty, 'Extension');
            tc.verifyEqual(pipTest.Processes, cell.empty(), 'Process');
            tc.verifyEqual(pipTest.Documentation, char.empty(), 'Doc');


        end

        function constructorWithValidFilename(tc)
            
            filename = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/pipelines/someName.mat';

            pipTest= Pipeline(filename);
            
            tc.verifyEqual(pipTest.Name, "someName", 'Name');
            tc.verifyEqual(pipTest.Folder, "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/pipelines", 'Folder');
            tc.verifyEqual(pipTest.Extension, ".mat", 'Extension');
            tc.verifyEqual(pipTest.Processes, cell.empty(), 'Process');
            tc.verifyEqual(pipTest.Documentation, char.empty(), 'Doc'); 
            
            
        end
        
        function constructorWithInvalidFolderInFile(tc)
            
            path = 'someFolder/someName.mat';
            
            tc.verifyError(@() Pipeline(path), '')
            
            
        end
        
        function setValidFolderWithCharacters(tc)
           
            pipTest = Pipeline();
            pipTest.setFolder('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1');
            
            tc.verifyEqual(pipTest.Folder, "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1");
            
        end
        
        function setValidFolderWithString(tc)
           
            pipTest = Pipeline();
            pipTest.setFolder("/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1");
            
            tc.verifyEqual(pipTest.Folder, "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1");
            
        end
        
        function setInvalidFolder(tc)
           
            pipTest = Pipeline();
            
            tc.verifyError(@() pipTest.setFolder('/mnt/SomeFolder'), '');
            tc.verifyError(@() pipTest.setFolder("/mnt/SomeFolder"), '');
            tc.verifyError(@() pipTest.setFolder(6), '');
            
        end
        
        function addProcessWithValidIndex(tc)
        
            pipTest = Pipeline();
            
            processesTest = PipelineTester.generateTestProcesses();
            
            % Adding process at the end
            for i = 1:length(processesTest)
                
                pipTest.addProcess(processesTest{i});
                tc.verifyEqual(pipTest.Processes{end}, processesTest{i});
            
            end
            
            pipTest.clear;
              
            % Adding processes at random position
            for i = 1:length(processesTest)
                randomIndex = randi([1 length(pipTest.Processes)+1], 1);
                
                pipTest.addProcess(processesTest{i}, randomIndex);
                tc.verifyEqual(pipTest.Processes{randomIndex}, processesTest{i});
            
            end
            
        end
        
        function addMultipleProcessesWithValidIndexes(tc)
        
            pipTest = Pipeline();
            processesTest = PipelineTester.generateTestProcesses();
            
            pipTest.addProcess(processesTest);
            tc.verifyEqual(pipTest.Processes, processesTest);
            
        end
        
        function addDuplicateProcess(tc)
            
            pipTest = Pipeline();
            
            processesTest = PipelineTester.generateTestProcesses();
            
            randomIndex = randi([1 length(processesTest)], 1);
            
            pipTest.addProcess(processesTest{randomIndex});
            
            tc.verifyError(@() pipTest.addProcess(processesTest{randomIndex}), ...
                'PipelineValidator:DuplicateProcess');
            
        end
        
        function addProcessWithInvalidIndexes(tc)
            
            pipTest = Pipeline();
            processesTest = PipelineTester.generateTestProcesses();
            
            invalidIndex = 100;
            tc.verifyError(@() pipTest.addProcess(processesTest(invalidIndex)), 'MATLAB:badsubscript');
            
            invalidIndex = 0;
            tc.verifyError(@() pipTest.addProcess(processesTest(invalidIndex)), 'MATLAB:badsubscript');
            
            invalidIndex = 'a';
            tc.verifyError(@() pipTest.addProcess(processesTest(invalidIndex)), 'MATLAB:badsubscript');
            
            
        end
        
        function addInvalidProcessOfWrongType(tc)
            
            eegPr = Process.create('add eeg position');
            megPr = Process.create('convert epochs to continue');
            
            pipTest = Pipeline();
            pipTest.addProcess(eegPr);
            
            tc.verifyError(@() pipTest.addProcess(megPr), 'PipelineValidator:InvalidProcessType');
            
        end
        
        function swapProcessesWithValidIndexes(tc)
            
            pipTest = Pipeline();
            processesTest = PipelineTester.generateTestProcesses();
            pipTest.addProcess(processesTest);
            
            randomIndexSource = randi([1 length(processesTest)], 1);
            
            while true
                randomIndexDestination = randi([1 length(processesTest)], 1);
                if randomIndexSource ~= randomIndexDestination
                    break
                end
            end
            
            processSource = pipTest.Processes{randomIndexSource};
            processDestination = pipTest.Processes{randomIndexDestination};
            
            pipTest.swapProcess(randomIndexSource, randomIndexDestination);
            
            tc.verifyEqual(pipTest.Processes{randomIndexSource}, processDestination);
            tc.verifyEqual(pipTest.Processes{randomIndexDestination}, processSource);
            
        end
        
        function moveProcessWithValidIndexes(tc)
            
            pipTest = Pipeline();
            processesTest = PipelineTester.generateTestProcesses();
            pipTest.addProcess(processesTest);
            
            randomIndexSource = randi([1 length(processesTest)], 1);
            
            while true
                randomIndexDestination = randi([1 length(processesTest)], 1);
                if randomIndexSource ~= randomIndexDestination
                    break
                end
            end
            
            processToMove = pipTest.Processes{randomIndexSource};
            
            pipTest.moveProcess(randomIndexSource, randomIndexDestination);
            
            tc.verifyEqual(processToMove, pipTest.Processes{randomIndexDestination});
            
        end
        
        function deleteProcessWithValidIndex(tc)
           
            pipTest = Pipeline();
            processesTest = PipelineTester.generateTestProcesses();
            pipTest.addProcess(processesTest);
            
            randomIndex = randi([1 length(processesTest)], 1);
            
            processToDelete = pipTest.Processes{randomIndex};
            
            pipTest.deleteProcess(randomIndex);
            
            tc.verifyTrue(~any(pipTest.isProcessesInPipeline(processToDelete)))
            
        end
        
        function clearPipelineTester(tc)
            
            pipTest = Pipeline();
            processesTest = PipelineTester.generateTestProcesses();
            pipTest.addProcess(processesTest);
            
            pipTest.clear;
            
            tc.verifyTrue(isempty(pipTest.Processes));
            
        end
        
        function savePipelineTester(tc)
        
            pipTestMat = Pipeline();
            pipTestMat.setFolder('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/pipelines'); 
            pipTestMat.setName('PipelineTester');
            pipTestMat.setExtension('.mat');
            
            processesTest = PipelineTester.generateTestProcesses();
            pipTestMat.addProcess(processesTest);
            
            pipTestJson = copy(pipTestMat);
            pipTestJson.setExtension('.json');
            
            pathToMatPipeline = fullfile(pipTestMat.Folder, strcat(pipTestMat.Name, pipTestMat.Extension));
            pathToJsonPipeline = fullfile(pipTestJson.Folder, strcat(pipTestJson.Name, pipTestJson.Extension));
            
            if isfile(pathToMatPipeline)
                delete(pathToMatPipeline);
            end
            
            if isfile(pathToJsonPipeline)
                delete(pathToJsonPipeline);
            end
            
            tc.verifyTrue(~isfile(pathToMatPipeline));
            tc.verifyTrue(~isfile(pathToJsonPipeline));
            
            pipTestMat.save();
            pipTestJson.save();
            
            tc.verifyTrue(isfile(pathToMatPipeline));
            tc.verifyTrue(isfile(pathToJsonPipeline));
            
            delete(pathToMatPipeline);
            delete(pathToJsonPipeline);
            
        end
        
        function searchProcessWithValidName(tc)
           
            rrf = Process.create('Review Raw Files');
            nf = Process.create('Notch Filter');
            bpf = Process.create('Band-Pass Filter');
            
            pipTest = Pipeline();
            pipTest.addProcess({rrf, nf, bpf});
            
            bpfFound = pipTest.getProcessIndexWithName('review_raw_files');
            tc.verifyEqual(bpfFound, 1);
            
            bpfFound = pipTest.getProcessIndexWithName('notch_filter');
            tc.verifyEqual(bpfFound, 2);
            
            bpfFound = pipTest.getProcessIndexWithName('band_pass_filter');
            tc.verifyEqual(bpfFound, 3);
            
        end
        
        function searchProcessWithInvalidName(tc)
           
            rrf = Process.create('Review Raw Files');
            nf = Process.create('Notch Filter');
            bpf = Process.create('Band-Pass Filter');
            
            pipTest = Pipeline();
            pipTest.addProcess({rrf nf bpf});
            
            rrfFound = pipTest.getProcessIndexWithName('review');
            tc.verifyEqual(rrfFound, -1);
            
            fFound = pipTest.getProcessIndexWithName(["notch_filter", "band_pass_filter"]);
            tc.verifyEqual(fFound, [2 3]);
            
            bpfFound = pipTest.getProcessIndexWithName(4);
            tc.verifyEqual(bpfFound, -1);
            
        end
        
        function verifyPipelineTypeWhenAddingProcess(tc)
           
            eegPr = Process.create('refine registration');
            specPr = Process.create('notch filter');
            genPr = Process.create('review raw files');
            
            pip = Pipeline();
            
            pip.addProcess(specPr);
            tc.verifyEqual(pip.Type, "specific");
            
            pip.addProcess(genPr);
            tc.verifyEqual(pip.Type, "general");
            
            pip.addProcess(eegPr);
            tc.verifyEqual(pip.Type, "eeg");
            
        end
        
        function verifyPipelineTypeWhenDeletingProcess(tc)
            
            eegPr = Process.create('refine registration');
            specPr = Process.create('notch filter');
            genPr = Process.create('review raw files');
            
            pip = Pipeline();
             
            pip.addProcess({specPr, genPr, eegPr});
            tc.verifyEqual(pip.Type, "eeg");
            
            pip.deleteProcess(3);
            tc.verifyEqual(pip.Type, "general");
            
            pip.deleteProcess(2);
            tc.verifyEqual(pip.Type, "specific");
            
            pip.deleteProcess(1);
            tc.verifyEqual(pip.Type, strings(1,1));
            
        end
        
    end
    
    methods 
        
        function verifyPipelineEqual(testCase, pip, expectedValues)
            
            testCase.verifyEqual(pip.Name, expectedValues{1});
            testCase.verifyEqual(pip.Folder, expectedValues{2});
            testCase.verifyEqual(pip.Extension, expectedValues{3});
            testCase.verifyEqual(pip.Processes, expectedValues{4});
            testCase.verifyEqual(pip.Documentation, expectedValues{5});

        end 
        
        function verifyPipelineClass(testCase, pip)
            
            testCase.verifyClass(pip.Name, 'string')
            testCase.verifyClass(pip.Folder, 'string');
            testCase.verifyClass(pip.Extension, 'string');
            testCase.verifyClass(pip.Documentation, 'char');
            testCase.verifyClass(pip.DateOfCreation, 'datetime');
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function structTest = generateTestStructure()
            
            name = 'Pipeline_Construct_With_Structure';
            folder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool';
            extension = '.json';
            processes = {Process.create('Refine Registration'), ...
                                    Process.create('Notch Filter'), ...
                                    Process.create('ICA')};
            documentation = 'I''ve been construct with a structure';

            structTest.Name = name;
            structTest.Folder = folder;
            structTest.Extension = extension;
            structTest.Processes = processes;
            structTest.Documentation = documentation;
            
            
        end
        
        function processesTest = generateTestProcesses()
            
            pr1 = Process.create('Add EEG Position');
            pr2 = Process.create('Refine Registration');
            pr3 = Process.create('Project Electrode On Scalp');
            pr4 = Process.create('Average Reference');
            pr5 = Process.create('Review Raw Files');
            pr6 = Process.create('Notch Filter');
            pr7 = Process.create('Band-Pass Filter');
            pr8 = Process.create('Power Spectrum Density');
            pr9 = Process.create('ICA');
            pr10 = Process.create('Export To BIDS');
            
            processesTest = {pr1, pr2, pr3, pr4, pr5, pr6, pr7, pr8, pr9, pr10};
            
        end
        
    end
    
end