classdef ProcessTester < matlab.unittest.TestCase
        
    properties (Access = private)
        
        gen;
        spec;
        eeg;
        meg;
        
    end
    
    methods(TestMethodSetup)
        
        function addDomainePath(~)
           
            addpath(genpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/domaine'));
        
        end
        
        function addUtilityPath(~)
           
            addpath(genpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool/utility'));
        
        end
        
        function loadProcesses(tc)
           
            allProcesses = Process.getAllProcesses();
            
            tc.gen = allProcesses.GeneralProcess;
            tc.spec = allProcesses.SpecificProcess;
            tc.eeg = allProcesses.EEG_Process;
            tc.meg = allProcesses.MEG_Process;
            
        end
          
    end
    
    methods(TestMethodTeardown)
        
    end
    
    methods (Test)
        
        function createScalarWithName(tc)
           
            type = {tc.gen, tc.spec, tc.eeg, tc.meg};
            class = {'GeneralProcess', 'SpecificProcess', 'EEG_Process', 'MEG_Process'};
            
            for i = 1:length(type)
                prNames = fieldnames(type{i});
                for j = 1:length(prNames)
                    
                    pr = Process.create(prNames{j});
                    tc.verifyClass(pr, class{i});
                    tc.verifyEqual(pr.Name, string(prNames{j}));
                    
                end
            end
            
            pr1 = Process.create('Review Raw Files');
            pr2 = Process.create('review-raw-files');
            pr3 = Process.create('review_raw_files');
            pr4 = Process.create('rEVIEW rAW fILES');
            
            assert((pr1 == pr2) && (pr2 == pr3) && (pr3 == pr4));
            
        end
        
        function createCellWithName(tc)
            
            type = {tc.gen, tc.spec, tc.eeg, tc.meg};
            class = {'GeneralProcess', 'SpecificProcess', 'EEG_Process', 'MEG_Process'};
            
            for i = 1:length(type)
                prNames = string(fieldnames(type{i}));
                pr = Process.create(prNames);
                
                cellCls = string(cellfun(@class, pr, 'UniformOutput', false));
                tc.verifyEqual(char(unique(cellCls)), class{i});
            end
            
        end
        
        function createWithCharCell(tc)
           
            type = {tc.gen, tc.spec, tc.eeg, tc.meg};
            class = {'GeneralProcess', 'SpecificProcess', 'EEG_Process', 'MEG_Process'};
            
            for i = 1:length(type)
                prNames = fieldnames(type{i})';
                pr = Process.create(prNames);
                
                cellCls = string(cellfun(@class, pr, 'UniformOutput', false));
                tc.verifyEqual(char(unique(cellCls)), class{i});
            end
            
        end
        
        function createWithProcessCell(tc)
           
            type = {tc.gen, tc.spec, tc.eeg, tc.meg};
            
            for i = 1:length(type)
                prNames = fieldnames(type{i})';
                pr1 = Process.create(prNames);
                
                pr2 = Process.create(pr1);
                
                tc.verifyEqual(pr1, pr2);
            end
            
        end
        
%         function createCellWithEegAndGeneral(tc)
%             
%             eegPr = tc.chooseRandomProcess('eeg', 2);
%             genPr = tc.chooseRandomProcess('gen', 2);
%             
%             expectedClass = 'EEG_Process';
%             
%             eegVector1 = Process.create([eegPr, genPr]);
%             tc.verifyClass(eegVector1, expectedClass);
%             
%             eegVector2 = Process.create([genPr, eegPr]);
%             tc.verifyClass(eegVector2, expectedClass);
%             
%         end
%         
%         function createVectorWithMegAndGeneral(tc)
%             
%             megPr = tc.chooseRandomProcess('meg', 2);
%             genPr = tc.chooseRandomProcess('gen', 2);
%             
%             expectedClass = 'MEG_Process';
%             
%             eegVector1 = Process.create([megPr, genPr]);
%             tc.verifyClass(eegVector1, expectedClass);
%             
%             eegVector2 = Process.create([genPr, megPr]);
%             tc.verifyClass(eegVector2, expectedClass);
%             
%         end
%         
%         function createVectorWithEegAndSpecific(tc)
%             
%             eegPr = tc.chooseRandomProcess('eeg', 2);
%             specPr = tc.chooseRandomProcess('spec', 2);
%             
%             expectedClass = 'EEG_Process';
%             
%             eegVector1 = Process.create([eegPr, specPr]);
%             tc.verifyClass(eegVector1, expectedClass);
%             
%             eegVector2 = Process.create([specPr, eegPr]);
%             tc.verifyClass(eegVector2, expectedClass);
%             
%         end
%         
%         function createVectorWithMegAndSpecific(tc)
%             
%             megPr = tc.chooseRandomProcess('meg', 2);
%             specPr = tc.chooseRandomProcess('spec', 2);
%             
%             expectedClass = 'MEG_Process';
%             
%             eegVector1 = Process.create([megPr, specPr]);
%             tc.verifyClass(eegVector1, expectedClass);
%             
%             eegVector2 = Process.create([specPr, megPr]);
%             tc.verifyClass(eegVector2, expectedClass);
%             
%         end
%         
%         function createVectorWithEegAndMeg(tc)
%             
%             eegPr = tc.chooseRandomProcess('eeg', 2);
%             megPr = tc.chooseRandomProcess('meg', 2);
%             
%             tc.verifyError(@() Process.create([eegPr, megPr]), 'MATLAB:UnableToConvert');
%             tc.verifyError(@() Process.create([megPr, eegPr]), 'MATLAB:UnableToConvert');
%             
%         end
%         
%         function createVectorWithGeneralAndSpecific(tc)
%             
%             genPr = tc.chooseRandomProcess('gen', 2);
%             specPr = tc.chooseRandomProcess('spec', 2);
%             
%             expectedClass = 'GeneralProcess';
%             
%             genVector1 = Process.create([genPr, specPr]);
%             tc.verifyClass(genVector1, expectedClass);
%             
%             genVector2 = Process.create([specPr, genPr]);
%             tc.verifyClass(genVector2, expectedClass);
%             
%         end
%         
%         function createVectorWithEegAndGeneralAndSpecific(tc)
%            
%             eegPr = tc.chooseRandomProcess('eeg', 2);
%             genPr = tc.chooseRandomProcess('gen', 2);
%             specPr = tc.chooseRandomProcess('spec', 2);
%             
%             expectedClass = 'EEG_Process';
%             
%             eegVector1 = Process.create([eegPr, genPr, specPr]);
%             tc.verifyClass(eegVector1, expectedClass);
%             
%             eegVector2 = Process.create([specPr, eegPr, genPr]);
%             tc.verifyClass(eegVector2, expectedClass);
%             
%         end
%         
        function createWithInvalidInput(tc)
           
            tc.verifyError(@() Process.create(4), 'ProcessValidator:InvalidCtorInput');
            
        end
        
        function createWithInvalidName(tc)
           
            tc.verifyError(@() Process.create(''), 'ProcessValidator:InvalidProcessName');
            
        end
        
        function createEegWithStructure(tc)
           
            eegPr1 = Process.create('add eeg position');
            param.file_type = 'Import or Default';
            param.electrode_file = 'someFolder/someFile.ext';
            param.cap = 'ColinSomething';
            eegPr1.setParameterWithStructure(param);
                        
            path = fullfile(pwd, 'ProcessTester.json');
            fileID = fopen(path, 'wt');
            fprintf(fileID, jsonencode(eegPr1, 'PrettyPrint', true));
            fclose(fileID);
            
            fileID = fopen(path); 
            raw = fread(fileID, inf);  
            fclose(fileID); 
            str = char(raw');
            eegStructLoaded = jsondecode(str);
            eegPr = Process.create(eegStructLoaded);
            
            delete(path);
            
            tc.verifyClass(eegPr, 'EEG_Process');
            tc.verifyEqual(eegPr.Parameters, param);
            
        end
        
%         function castSpecificProcessWithClass(tc)
%            
%             specPr = Process.create('notch Filter');
%             tc.verifyClass(specPr, 'SpecificProcess');
%             
%             eegPr = cast(specPr, 'EEG_Process');
%             tc.verifyClass(eegPr, 'EEG_Process');
%             
%             megPr = cast(specPr, 'MEG_Process');
%             tc.verifyClass(megPr, 'MEG_Process');
%             
%             genPr = cast(specPr, 'GeneralProcess');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%         end
        
%         function castGeneralProcessWithClass(tc)
%            
%             genPr = Process.create('review raw files');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%             eegPr = cast(genPr, 'EEG_Process');
%             tc.verifyClass(eegPr, 'EEG_Process');
%             
%             megPr = cast(genPr, 'MEG_Process');
%             tc.verifyClass(megPr, 'MEG_Process');
%             
%             specPr = cast(genPr, 'SpecificProcess');
%             tc.verifyClass(specPr, 'SpecificProcess', 'General To Specific');
%             
%         end
        
%         function castMegProcessWithClass(tc)
%            
%             megPr = Process.create('convert epochs to continue');
%             tc.verifyClass(megPr, 'MEG_Process');
%             
%             tc.verifyError(@() cast(megPr, 'EEG_Process'), 'ProcessConverter:InvalidCasting');
%                         
%             genPr = cast(megPr, 'GeneralProcess');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%             specPr = cast(megPr, 'SpecificProcess');
%             tc.verifyClass(specPr, 'SpecificProcess', 'General To Specific');
%             
%         end
        
%         function castEegProcessWithClass(tc)
%            
%             eegPr = Process.create('add eeg position');
%             tc.verifyClass(eegPr, 'EEG_Process');
%             
%             tc.verifyError(@() cast(eegPr, 'MEG_Process'), 'ProcessConverter:InvalidCasting');
%                         
%             genPr = cast(eegPr, 'GeneralProcess');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%             specPr = cast(eegPr, 'SpecificProcess');
%             tc.verifyClass(specPr, 'SpecificProcess', 'General To Specific');
%             
%         end
        
%         function castSpecificProcessWithType(tc)
%            
%             specPr = Process.create('notch Filter');
%             tc.verifyClass(specPr, 'SpecificProcess');
%             
%             eegPr = castWithType(specPr, 'EEG');
%             tc.verifyClass(eegPr, 'EEG_Process');
%             
%             megPr = castWithType(specPr, 'MEG');
%             tc.verifyClass(megPr, 'MEG_Process');
%             
%             genPr = castWithType(specPr, 'General');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%         end
        
%         function castGeneralProcessWithType(tc)
%            
%             genPr = Process.create('review raw files');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%             eegPr = castWithType(genPr, 'EEG');
%             tc.verifyClass(eegPr, 'EEG_Process');
%             
%             megPr = castWithType(genPr, 'MEG');
%             tc.verifyClass(megPr, 'MEG_Process');
%             
%             specPr = castWithType(genPr, 'Specific');
%             tc.verifyClass(specPr, 'SpecificProcess', 'General To Specific');
%             
%         end
        
%         function castMegProcessWithType(tc)
%            
%             megPr = Process.create('convert epochs to continue');
%             tc.verifyClass(megPr, 'MEG_Process');
%             
%             tc.verifyError(@() castWithType(megPr, 'EEG'), 'ProcessConverter:InvalidCasting');
%                         
%             genPr = castWithType(megPr, 'general');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%             specPr = castWithType(megPr, 'specific');
%             tc.verifyClass(specPr, 'SpecificProcess', 'General To Specific');
%             
%         end
        
%         function castEegProcessWithType(tc)
%            
%             eegPr = Process.create('add eeg position');
%             tc.verifyClass(eegPr, 'EEG_Process');
%             
%             tc.verifyError(@() castWithType(eegPr, 'MEG'), 'ProcessConverter:InvalidCasting');
%                         
%             genPr = castWithType(eegPr, 'general');
%             tc.verifyClass(genPr, 'GeneralProcess');
%             
%             specPr = castWithType(eegPr, 'specific');
%             tc.verifyClass(specPr, 'SpecificProcess', 'General To Specific');
%             
%         end
        
        function setParametersWithInvalidValue(tc)
           
            nf = Process.create('notch filter');
            tc.verifyError(@() nf.setParameter('Frequence', '60'), 'ProcessValidator:InvalidParameterClass');
            
        end
        
        function setParametersWithInvalidField(tc)
           
            nf = Process.create('notch filter');
            tc.verifyWarning(@() nf.setParameter('Frequences', 60), '');
            
        end
        
        function equalityBetweenTwoScalars(tc)
        
            specPr1 = Process.create('notch filter');
            specPr1.setParameter('Frequence', 60);
            
            specPr2 = Process.create('notch filter');
            param.Frequence = 60;
            specPr2.setParameterWithStructure(param);
            
            tc.verifyTrue(specPr1 == specPr2);
            
        end
        
        function equalityBetweenCellsAndScalar(tc)
        
            specPr1 = Process.create('notch filter');
            specPr1.setParameter('Frequence', 60);
            
            specPr2 = Process.create('band pass filter');
            param.Frequence = [20 80];
            specPr2.setParameterWithStructure(param);
            
            specPr3 = Process.create('power spectrum density');
            specPr3.setParameter('Window_Length', 10);
                        
            specPr4 = Process.create('ica');
            specPr4.setParameter('Number_Of_Components', 32);
            
            specVector = [specPr1 specPr2 specPr3 specPr4];
            
            tc.verifyEqual(logical([1 0 0 0]), specPr1 == specVector);
            tc.verifyEqual(logical([1 0 0 0]), specVector == specPr1);
            tc.verifyEqual(logical([0 1 0 0]), specPr2 == specVector);
            tc.verifyEqual(logical([0 1 0 0]), specVector == specPr2);
            tc.verifyEqual(logical([0 0 1 0]), specPr3 == specVector);
            tc.verifyEqual(logical([0 0 1 0]), specVector == specPr3);
            
        end
        
        function supportedDatasetFormat(tc)
           
            genPr = Process.create('review raw files');
            specPr = Process.create('notch filter');
            eegPr = Process.create('add eeg position');
            megPr = Process.create('convert epochs to continue');
            
            tc.verifyEqual(genPr.getSupportedDatasetExtension, [".eeg", ".edf", ".meg4"], 'General');
            tc.verifyEqual(specPr.getSupportedDatasetExtension, [".eeg", ".edf", ".meg4"], 'Specific');
            tc.verifyEqual(eegPr.getSupportedDatasetExtension, [".eeg", ".edf"], 'EEG');
            tc.verifyEqual(megPr.getSupportedDatasetExtension, ".meg4", 'MEG');
            
        end
        
    end
    
    methods (Access = private)
        
        function process = chooseRandomProcess(tc, type, nb)
        
            indexes = randi(length(tc.(type)), 1, nb);
            prNames = string(fieldnames(tc.(type))');
            process = Process.create(prNames(indexes));
            
        end
        
    end
    
end