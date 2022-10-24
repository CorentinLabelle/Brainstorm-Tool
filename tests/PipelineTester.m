classdef PipelineTester < matlab.unittest.TestCase

    properties (Access = private)
    
        PipelineName = "Pipeline Name";
        PipelineFolder = "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1";
        PipelineExtension = ".json";
        
    end
    
    methods(TestMethodSetup)
        
    end
    
    methods(TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function emptyConstructor(tc)
            pipTest = Pipeline();
            tc.verifyTrue(pipTest.isDefault());            
        end

        function constructorWithInvalidFilename(tc)
            tc.verifyError(@() Pipeline('someFile'), ?MException); 
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
        
        function setNameWithString(tc)
            pip = Pipeline();
            pip = pip.setName(string(tc.PipelineName));
            tc.verifyEqual(pip.getName(), tc.PipelineName);            
        end
        
        function setNameWithChar(tc)
            pip = Pipeline();
            pip = pip.setName(char(tc.PipelineName));
            tc.verifyEqual(pip.getName(), tc.PipelineName);            
        end
        
        function setInvalidName(tc)
            pip = Pipeline();
            tc.verifyError(@() pip.setName(5), ?MException);            
        end
        
        function setFolderWithCharacters(tc)
            pipTest = Pipeline();
            pipTest = pipTest.setFolder(char(tc.PipelineFolder));
            tc.verifyEqual(pipTest.getFolder(), tc.PipelineFolder);            
        end
        
        function setFolderWithString(tc)
            pipTest = Pipeline();
            pipTest = pipTest.setFolder(string(tc.PipelineFolder));
            tc.verifyEqual(pipTest.getFolder(), tc.PipelineFolder); 
        end
        
        function setInvalidFolder(tc)
            pipTest = Pipeline();
            tc.verifyError(@() pipTest.setFolder(6), ?MException);            
        end
        
        function setExtensionWithCharacters(tc)
            pipTest = Pipeline();
            pipTest = pipTest.setExtension(char(tc.PipelineExtension));
            tc.verifyEqual(pipTest.getExtension(), tc.PipelineExtension);
        end
        
        function setExtensionWithString(tc)
            pipTest = Pipeline();
            pipTest = pipTest.setExtension(string(tc.PipelineExtension));
            tc.verifyEqual(pipTest.getExtension(), tc.PipelineExtension);
        end
        
        function setInvalidExtension(tc)
            pipTest = Pipeline();
            tc.verifyError(@() pipTest.setExtension(6), ?MException);
        end
        
        function addProcessAtTheEnd(tc)
            processesTest = PipelineTester.generateTestProcesses();
        
            pipTest = Pipeline();            
            for i = 1:length(processesTest)                
                pipTest = pipTest.addProcess(processesTest{i});
                tc.verifyEqual(pipTest.Processes.getProcess{end}, processesTest{i});            
            end
            
        end
        
        function addProcessAtRandomPosition(tc)
            processesTest = PipelineTester.generateTestProcesses();
              
            pipTest = Pipeline();
            for i = 1:length(processesTest)
                randomIndex = randi([1 length(pipTest.Processes)+1], 1);                
                pipTest.addProcess(processesTest{i}, randomIndex);
                tc.verifyEqual(pipTest.Processes.getProcess(randomIndex), processesTest{i});            
            end
            
        end
        
        function addMultipleProcessesAtTheEnd(tc)
            rrf = Process.create('review raw files');
            aep = Process.create('add eeg position');
            processToAdd = {rrf, aep};
        
            pipTest = Pipeline();
            pipTest.addProcess(processToAdd);
            tc.verifyEqual(pipTest.Processes.getProcess(), processToAdd, 'first');
            
        end
        
        function addMultipleProcessesAtRandomPosition(tc)
            pr1 = Process.create('Review Raw Files');
            pr2 = Process.create('Add EEG Position');
            pr3 = Process.create('Notch Filter');
            pr4 = Process.create('Band-Pass Filter');
            pr5 = Process.create('Power Spectrum Density');
            pr6 = Process.create('ICA');
            pr7 = Process.create('Export To BIDS');
            processToAdd = {pr4, pr5, pr6, pr7};
            
            pipTest = Pipeline();
            pipTest.addProcess(pr1);
            pipTest.addProcess(pr2);
            pipTest.addProcess(pr3);
            pipTest.addProcess(processToAdd, 2);
            tc.verifyEqual(pipTest.Processes.getProcess(1), pr1, '1');
            tc.verifyEqual(pipTest.Processes.getProcess(2), pr4, '2');
            tc.verifyEqual(pipTest.Processes.getProcess(3), pr5, '3');
            tc.verifyEqual(pipTest.Processes.getProcess(4), pr6, '4');
            tc.verifyEqual(pipTest.Processes.getProcess(5), pr7, '5');
            tc.verifyEqual(pipTest.Processes.getProcess(6), pr2, '6');
            tc.verifyEqual(pipTest.Processes.getProcess(7), pr3, '7');
            
        end
        
        function addProcessWithInvalidPosition(tc)
            pr = Process.create('review raw files');
            pipTest = Pipeline();
            tc.verifyError(@() pipTest.addProcess(pr, 100), ?MException);
        end
        
        function addProcessOfWrongType(tc)
            eegPr1 = Process.create('add eeg position');
            eegPr2 = Process.create('project electrode on scalp');
            megPr = Process.create('convert epochs to continue');
            
            pipTest = Pipeline();
            pipTest.addProcess(eegPr1);
            pipTest.addProcess(eegPr2);
            tc.verifyError(@() pipTest.addProcess(megPr), ?MException);            
        end        
        
        function addDuplicateProcess(tc)
            pr = Process.create('add eeg position');
            pipTest = Pipeline();      
            pipTest.addProcess(pr);
            tc.verifyError(@() pipTest.addProcess(pr), ?MException);            
        end
        
        function addProcessWithInvalidIndexes(tc)
            nf = Process.create('notch filter');
            
            pipTest = Pipeline();
            
            invalidIndex = 100;
            tc.verifyError(@() pipTest.addProcess(nf, invalidIndex), 'MATLAB:badsubscript');
            
            invalidIndex = 0;
            tc.verifyError(@() pipTest.addProcess(nf, invalidIndex), 'MATLAB:badsubscript');
            
            invalidIndex = 'a';
            tc.verifyError(@() pipTest.addProcess(nf, invalidIndex), 'MATLAB:badsubscript');
            
            
        end
        
        function clearPipelineTester(tc)
            bpf = Process.create('band pass filter');
            pipTest = Pipeline();
            pipTest.addProcess(bpf);
            pipTest.clear;
            tc.verifyTrue(pipTest.Processes.isEmpty());
        end
        
        function deleteProcessWithValidIndex(tc)
            rrf = Process.create('review raw files');
            ica = Process.create('ica');
            etb = Process.create('export to bids');
           
            pipTest = Pipeline();
            pipTest.addProcess(rrf);
            pipTest.addProcess(ica);
            pipTest.addProcess(etb);
            
            pipTest.deleteProcess(2);
            
            tc.verifyTrue(pipTest.Processes.getNumberOfProcess() == 2);
            tc.verifyEqual(pipTest.Processes.getProcess(1), rrf);
            tc.verifyEqual(pipTest.Processes.getProcess(2), etb);
            
        end
        
        function moveProcessWithValidIndexes(tc)
            ica = Process.create('ica');
            nf = Process.create('notch filter');
            bpf = Process.create('band pass filter');
            etb = Process.create('export to bids');
            
            pipTest = Pipeline();
            
            pipTest.addProcess(nf);
            pipTest.addProcess(bpf);
            pipTest.addProcess(ica);
            pipTest.addProcess(etb);
            
            pipTest.moveProcess(2, 4);
            
            tc.verifyEqual(pipTest.Processes.getProcess(1), nf);
            tc.verifyEqual(pipTest.Processes.getProcess(2), ica);
            tc.verifyEqual(pipTest.Processes.getProcess(3), etb);
            tc.verifyEqual(pipTest.Processes.getProcess(4), bpf);
            
        end
        
        function swapProcessesWithValidIndexes(tc)
            ica = Process.create('ica');
            nf = Process.create('notch filter');
            bpf = Process.create('band pass filter');
            etb = Process.create('export to bids');
            
            pipTest = Pipeline();
            
            pipTest.addProcess(nf);
            pipTest.addProcess(bpf);
            pipTest.addProcess(ica);
            pipTest.addProcess(etb);
            
            pipTest.swapProcess(2, 4);
            
            tc.verifyEqual(pipTest.Processes.getProcess(1), nf);
            tc.verifyEqual(pipTest.Processes.getProcess(2), etb);
            tc.verifyEqual(pipTest.Processes.getProcess(3), ica);
            tc.verifyEqual(pipTest.Processes.getProcess(4), bpf);
            
        end
        
        function copyOfPipeline(tc)
            
            pip1 = Pipeline();
            pip2 = copy(pip1);
            pip1.setName(tc.PipelineName);
            
            tc.verifyEqual(pip1.getName(), tc.PipelineName);
            tc.verifyNotEqual(pip2.getName(), tc.PipelineName);
            
        end
        
        function isProcessIn(tc)
            rrf = Process.create('review raw files');
            nf = Process.create('notch filter');
            bpf = Process.create('band pass filter');
            ica = Process.create('ica');
            aep = Process.create('add eeg position');
            
            pip = Pipeline();
            pip.addProcess({rrf, nf, bpf, ica});            
            tc.verifyTrue(pip.isProcessIn(rrf));            
            tc.verifyEqual(pip.isProcessIn({bpf, ica, aep}), logical([1 1 0]));
            
        end
        
        function convertToCharacters(tc)
            pip = Pipeline();
            pipAsChars = pip.convertToCharacters();
            tc.verifyClass(pipAsChars, 'char');
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
            folder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/tests';
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