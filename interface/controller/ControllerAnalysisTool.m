classdef ControllerAnalysisTool < Controller
    
    properties
        
        % Paths
        WorkingFolder; % [char]
        BstDataBasePath; % [char]
                
        % Folder Name
        AppFolderName = "__APP__";
        
        % Variables
        Analyzer; % [Basic_Analyzer]
        BstUtil; % [BstUtility]
        
    end
    
    methods
        
        function obj = ControllerAnalysisTool()
            
            obj@Controller();

            obj.setDefaultWorkingFolder();
            
            if ~isdeployed()
                obj.startBrainstorm();
            end
            
            obj.BstUtil = BstUtility.instance();
            
        end
        
        function startBrainstorm(obj)
           
            startBrainstorm@Controller(obj);
            obj.asgBstDataBasePath(bst_get('BrainstormDbDir'));
            
        end
        
        function switchType(obj, type)
           
            switchType@Controller(obj, type);
            obj.createAnalyzer;
            
        end
        
        function createAnalyzer(obj)
           
            switch obj.Type
                
                case 'EEG'
                    obj.Analyzer = EEG_Analyzer.instance();
                    
                case 'MEG'
                    obj.Analyzer = MEG_Analyzer.instance();
                    
            end
            
        end
        
        function str = printCurrentPipeline(obj)
            
            str = obj.CurrentPipeline.print();
            
        end
        
        function runPipeline(obj, sFiles)
            
           obj.CurrentPipeline.run(sFiles);
            
        end

        function runProcess(~, process, sFiles)
           
            process.run(sFiles);
            
        end
        
        function supportedExtensions = getSupportedExtension(obj)
           
            supportedExtensions = obj.Analyzer.getExtensionSupported;
            
        end
        
        function sFilesOut = reviewRawFiles(obj, subjectName, rawFilePath)
            
            sFilesOut = obj.Analyzer.reviewRawFiles(subjectName, rawFilePath);
            
        end
        
        function sFilesOut = notchFilter(obj, sFiles, frequence)
           
            sFilesOut = obj.Analyzer.notchFilter(sFiles, frequence);
            
        end
        
        function sFilesOut = bandPassFilter(obj, sFiles, frequence)
           
            sFilesOut = obj.Analyzer.bandPassFilter(sFiles, frequence);
            
        end
        
        function sFilesOut = powerSpectrumDensity(obj, sFiles, windowLength)
            
            sFilesOut = obj.Analyzer.powerSpectrumDensity(sFiles, windowLength);
            
        end
        
        function sFilesOut = convertEpochsToContinue(obj, sFiles)
            
           assert(isa(obj.Analyzer, 'MEG_Analysis'));
           
           sFilesOut = obj.Analyzer.convertEpochsToContinue(sFiles);
            
        end
        
        function sFilesOut = addEegPosition(obj, sFiles, fileType, cap, electrodeFile)
            
            assert(isa(obj.Analyzer, 'EEG_Analysis'));
            
            sFilesOut = obj.Analyzer.addEegPosition(sFiles, fileType, cap, electrodeFile);
        
        end
        
        function sFilesOut = refineRegistration(obj, sFiles)
       
           sFilesOut = obj.Analyzer.refineRegistration(sFiles);
            
        end
        
        function sFilesOut = projectElectrodesOnScalp(obj, sFiles)
       
           sFilesOut = obj.Analyzer.projectElectrodesOnScalp(sFiles);
            
        end
        
        function sFilesOut = averageReference(obj, sFiles)
       
           sFilesOut = obj.Analyzer.averageReference(sFiles);
            
        end
        
        function sFilesOut = ica(obj, sFiles, nbComponents)
       
           sFilesOut = obj.Analyzer.ica(sFiles, nbComponents);
            
        end
        
        function sFilesOut = detectCardiacArtifact(obj, sFiles, channelName, eventName)
           
            sFilesOut = obj.Analyzer.detectCardiacArtifact(sFiles, channelName, eventName);
            
        end
        
        function sFilesOut = detectBlinkArtifact(obj, sFiles, channelName, eventName)
           
            sFilesOut = obj.Analyzer.detectBlinkArtifact(sFiles, channelName, eventName);
            
        end
        
        function sFilesOut = detectOtherArtifact(obj, sFiles, lowFrequence, highFrequence)
           
            sFilesOut = obj.Analyzer.detectOtherArtifact(sFiles, lowFrequence, highFrequence);
            
        end
        
        function sFilesOut = removeSimultaneaousEvents(obj, sFiles, eventToRemove, eventToTarget)
            
            sFilesOut = obj.Analyzer.removeSimultaneaousEvents(sFiles, eventToRemove, eventToTarget);
            
        end
        
        function sFilesOut = sspCardiac(obj, sFiles, eventName)
            
            sFilesOut = obj.Analyzer.sspCardiac(sFiles, eventName);
            
        end
        
        function sFilesOut = sspBlink(obj, sFiles, eventName)
           
            sFilesOut = obj.Analyzer.sspBlink(sFiles, eventName);
            
        end
        
        function sFilesOut = sspGeneric(obj, sFiles, eventName)
            
            sFilesOut = obj.Analyzer.sspGeneric(sFiles, eventName);
            
        end
        
        function sFilesOut = exportToBids(obj, sFiles, BidsPath)
           
            sFilesOut = obj.Analyzer.exportToBids(sFiles, BidsPath);
            
        end
        
        function sFilesOut = rejectBadTrials(obj, sFiles, MEGgrad, MEGmagneto, EEG, SEEG_ECOG, EOG, ECG)
            
            sFilesOut = obj.Analyzer.rejectBadTrials(sFiles, MEGgrad, MEGmagneto, EEG, SEEG_ECOG, EOG, ECG);
            
        end
        
        function createProtocol(obj, protocolName)
            
            obj.BstUtil.createProtocol(protocolName); 
            
        end
        
        function setProtocol(obj, protocolIndex)

            obj.BstUtil.setProtocol(protocolIndex);

        end

        function protocolIndex = getProtocolIndex(obj, protocolName)
           
            protocolIndex = obj.BstUtil.getProtocolIndex(protocolName);

        end


        function deleteProtocol(obj, protocolName)
            
            obj.BstUtil.deleteProtocol(protocolName);
            
        end
        
        function renameEvent(obj, sFiles, oldName, newName)
           
            obj.Analyzer.renameEvent(sFiles, oldName, newName);
            
        end
        
        function deleteEvent(obj, sFiles, eventName)
           
            obj.Analyzer.deleteEvent(sFiles, eventName);
            
        end
        
        function viewComponents(obj, sFiles)
            
            obj.Analyzer.viewComponents(sFiles);
            
        end
        
        function allProtocols = getAllProtocols(obj)
            
            allProtocols = obj.BstUtil.getAllProtocols();
            
        end
        
        function allEvents = getEvents(obj, sFiles)
            
            allEvents = obj.BstUtil.getEvents(sFiles);
            
        end
        
        function [filePath, sFile] = exportData(obj, sFile, folder, extension)
            
            [filePath, sFile] = obj.BstUtil.exportData(sFile, folder, extension);
            
        end
        
        function asgWorkingFolderPath(obj, path)
            
           
           obj.WorkingFolder = fullfile(path, obj.AppFolderName);
            
        end
        
        function path = getWorkingFolderPath(obj)
            
           path = obj.WorkingFolder;
            
        end
       
        function asgBstDataBasePath(obj, path)
            
           obj.BstDataBasePath = path;
            
        end
        
        function path = getBstDataBasePath(obj)
            
           path = obj.BstDataBasePath;
            
        end

        function anatomyFileFormat = getAnatomyFileFormat(obj)
            
            switch obj.Type
                case 'EEG'
                    anatomyFileFormat = "FreeSurfer-fast";
                    
                case 'MEG'
                    anatomyFileFormat = "FreeSurfer";
            end
            
        end
        
        function checkIfChannelIsInChannelFile(obj, sFiles, channelToCheck)
            obj.BstUtil.checkIfChannelIsInChannelFile(sFiles, channelToCheck);
        end
        
        function createWorkingFolder(obj)
           
            if ~isfolder(obj.getWorkingFolderPath)
                mkdir(obj.getWorkingFolderPath);
            end
            
        end

        function setDefaultWorkingFolder(obj)

            username = getenv('USERNAME');
            if ispc
                obj.WorkingFolder = fullfile("C:/Users/", username, "/Desktop");
            elseif isunix
                obj.WorkingFolder = fullfile("/home/", username);
            elseif ismac
                obj.WorkingFolder = fullfile("/Users/", username, "/Desktop");
            end

        end
    end
end

