classdef PipelineBuilderTester < matlab.uitest.TestCase & matlab.mock.TestCase
    
    properties (Access = private)
        
        App;
        PipelineName = 'PipelineTester.json';
        PipelineFolder = PathsGetter.getTestFolder();
        
    end
        
    methods (TestMethodSetup)
    
        function startApp(tc)
            import matlab.mock.actions.AssignOutputs
            
            [mockChooser, behaviorChooser] = tc.createMock(?FileChooser);
            [mockTextInput, behaviorTextInput] = tc.createMock(?TextInput);
            
            tc.App = Pipeline_Builder('eeg', mockChooser, mockTextInput);
            
            when(behaviorChooser.chooseFile(...
                tc.App.controller.getPipelineSupportedExtensionToGetFile(), ...
                'Select file', ...
                tc.App.controller.getPipelineSearchPath()...
                ),AssignOutputs(tc.PipelineName,tc.PipelineFolder, 1));
            
            when(behaviorChooser.chooseFile(...
                tc.App.controller.getSupportedDatasetFormatToGetFile(), ...
                'Select Data file', ...
                tc.App.controller.getRawDataSearchPath(), ...
                'on'...
                ),AssignOutputs('b1.eeg','/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data', 1));
            
            when(behaviorTextInput.enterText(...
                'Enter the Subject Name:', ...
                'Subject Name'),...
                AssignOutputs('Harry'));
             
        end
       
    end
    
    methods (TestMethodTeardown)
        
        function closeApp(tc)
            delete(tc.App);
        end
        
        function deleteCreatedPipeline(tc)
           
            filePath = fullfile(tc.PipelineFolder, tc.PipelineName);
            if isfile(filePath)
                delete(filePath);
            end
            
        end
        
    end
    
    methods (Test)
        
        function savePipeline(tc)
            
            tc.verifyTrue(~isfile(fullfile(tc.PipelineFolder, tc.PipelineName)));

            tc.createAndSavePipeline();
            
            tc.verifyTrue(isfile(fullfile(tc.PipelineFolder, tc.PipelineName)));
            
        end
        
        function clearPipeline(tc)
           
            tc.selectAllEegProcess();
            
            EegCheckBoxes = tc.App.EEGProcessesPanel.Children;
            for i = 1:length(EegCheckBoxes)
                tc.verifyTrue(EegCheckBoxes(i).Value);
            end
            
            tc.press(tc.App.ClearPipelineButton);
            
            for i = 1:length(EegCheckBoxes)
                tc.verifyFalse(EegCheckBoxes(i).Value);
            end
            
        end
        
        function importPipeline(tc)
            
            pathToPipeline = tc.createAndSavePipeline();
            pip1 = Pipeline(pathToPipeline);

            tc.press(tc.App.ClearPipelineButton);
            
            tc.press(tc.App.ImportPipelineButton);
            tc.press(tc.App.SavePipelineButton);
            pip2 = Pipeline(pathToPipeline);
            
            EegCheckBoxes = tc.App.EEGProcessesPanel.Children;
            for i = 1:length(EegCheckBoxes)
                tc.verifyTrue(EegCheckBoxes(i).Value);
            end
            
            tc.compareTwoPipelines(pip1, pip2);
            
            delete(pathToPipeline);
            
        end
      
        function switchType(tc)
            
            tc.choose(tc.App.PipelineTypeDropDown, 'MEG');
            tc.verifyTrue(strcmpi(tc.App.controller.getType, 'MEG'));
            
            tc.choose(tc.App.PipelineTypeDropDown, 'EEG');
            tc.verifyTrue(strcmpi(tc.App.controller.getType, 'EEG'));
            
        end
        
    end
    
    methods (Access = private)
        
        function pipelinePath = createAndSavePipeline(tc)
            
            tc.enterPipelineName(tc.PipelineName);
            tc.enterPipelineFolder(tc.PipelineFolder);
            tc.selectAllEegProcess();
            tc.press(tc.App.SavePipelineButton);
            
            pipelinePath = fullfile(tc.PipelineFolder, tc.PipelineName);
            
        end
        
        function enterPipelineName(tc, pipelineName)
           tc.type(tc.App.PipelineNameEditField, pipelineName);
        end
        
        function enterPipelineFolder(tc, pipelineFolder)
           tc.type(tc.App.SaveinFolderEditField, pipelineFolder);
        end
        
        function selectAllEegProcess(tc)
            
            tc.selectReviewRawFiles();
            tc.selectAddEegPositionWithDefaultPattern();
            tc.selectRefineRegistration();
            tc.selectProjectElectrodeOnScalp();
            tc.selectNotchFilterSpecificFrequence();
            tc.selectBandPassFilter();
            tc.selectPowerSpectrumDensity();
            tc.selectAverageReference();
            tc.selectIca();
            tc.selectConvertToBids();
            
        end
        
        function selectReviewRawFiles(tc)
            
            tc.press(tc.App.EEGReviewRawFilesCheckBox);
            
            subjectName = {'Harry', 'Ron'};
            
            rawFilesPath = {...
                {   '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/tests/DataQuickImportTester/S01/actives_electrodes_visual_stim_s1_07.eeg',...
                    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/tests/DataQuickImportTester/S01/actives_electrodes_visual_stim_s1_11.eeg'}, ...
                {   '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/tests/DataQuickImportTester/S02/actives_electrodes_visual_stim_s2_02.eeg',...
                    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/tests/DataQuickImportTester/S02/actives_electrodes_visual_stim_s2_05.eeg'}};
                             
            tc.App.controller.addSubject(subjectName, rawFilesPath);
            
        end
        
        function selectAddEegPositionWithDefaultPattern(tc)
            tc.press(tc.App.AddEEGPositionCheckBox);
            tc.choose(tc.App.UseDefaultPatternButton);
            tc.choose(tc.App.Colin27BrainProductsEasyCap64Button);
        end
        
        function selectRefineRegistration(tc)
            tc.press(tc.App.RefineRegistrationCheckBox);
        end
        
        function selectProjectElectrodeOnScalp(tc)
            
            tc.press(tc.App.ProjectElectrodeonScalpCheckBox);
            
        end
        
        function selectNotchFilterSpecificFrequence(tc)
            
            tc.press(tc.App.NotchFilterEEGCheckBox);
            tc.choose(tc.App.SpecificFrequenceButton);
            tc.type(tc.App.Frequence, '10, 90');
            
        end
        
        function selectNotchFilterEurope(tc)
            
            tc.press(tc.App.NotchFilterEEGCheckBox);
            tc.choose(tc.App.EuropeButton);
            
        end
        
        function selectBandPassFilter(tc)
            
            tc.press(tc.App.BandPassFilterEEGCheckBox);
            tc.type(tc.App.LowCutOffHzEditField, 10);
            tc.type(tc.App.HighCutOffHzEditField, 90);
            
        end
        
        function selectPowerSpectrumDensity(tc)
            
            tc.press(tc.App.PowerSpectrumDensityEEGCheckBox);
            tc.type(tc.App.WindowLengthEditField, 10);
            
        end
        
        function selectAverageReference(tc)
            
            tc.press(tc.App.AverageReferenceCheckBox);
            
        end
        
        function selectIca(tc)
            
            tc.press(tc.App.ICAEEGCheckBox);
            tc.type(tc.App.NumberofComponentsICAEditField, 32);
            
        end
        
        function selectConvertToBids(tc)
            
            tc.press(tc.App.ConverttoBIDSEEGCheckBox);
            tc.type(tc.App.BIDSFolderPathEditField, pwd);
            tc.type(tc.App.BIDSFolderNameEditField, 'Bids_Pipeline_Tester');
            
        end
                
        function savePipelineToJson(tc)
        
            tc.press(tc.App.SavePipelineButton);
            tc.verifyTrue(isfile(fullfile(tc.PipelineFolder, tc.PipelineName)));
            
        end
        
        function compareTwoPipelines(tc, pip1, pip2)
           
            tc.verifyTrue(pip1 == pip2);
            
        end
        
    end
    
end