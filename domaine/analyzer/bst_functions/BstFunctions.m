classdef BstFunctions < handle
    
    methods (Access = public)
        
        function sFiles = createSubject(~, listOfParameters, ~)   
            subjectName = listOfParameters.getConvertedValue(1);
            for i = 1:length(subjectName)
                db_add_subject(subjectName{i}, [], 1, 0);
            end
            sFiles = [];
        end
        
        function sFiles = importAnatomy(~, listOfParameters, ~)
            subjects = listOfParameters.getConvertedValue(1);
            anatomyPath = listOfParameters.getConvertedValue(2);
            fileFormat = listOfParameters.getConvertedValue(3);
            
            sFiles = cell(1, length(subjects));
            for i = 1:length(subjects)       
                sFiles{i} = Bst_ImportAnatomy(subjects{i}, anatomyPath{i}, fileFormat);
            end
            sFiles = cell2mat(sFiles);
        end
        
        function sFiles = reviewRawFiles(~, listOfParameters, ~)
            subjects = listOfParameters.getConvertedValue(1);
            rawFilesPath = listOfParameters.getConvertedValue(2);
            fileFormat = listOfParameters.getConvertedValue(3);
            
            sFiles = cell(1, length(subjects));
            for i = 1:length(subjects)       
                sFiles{i} = Bst_ReviewRawFiles(subjects{i}, rawFilesPath{i}, fileFormat);
            end
            sFiles = cell2mat(sFiles);            
        end
        
        function sFiles = splitRawFiles(~, listOfParameters, sFiles)
            eventName = listOfParameters.getConvertedValue(1);
            sFiles = Bst_SplitRawFiles(eventName, sFiles);
        end
         
        function sFiles = notchFilter(obj, listOfParameters, sFiles)
            frequence = listOfParameters.getConvertedValue(1);            
            sFiles = Bst_NotchFilter(sFiles, frequence, char(obj.SensorType));
        end
        
        function sFiles = bandPassFilter(obj, listOfParameters, sFiles)
            frequence = listOfParameters.getConvertedValue(1);
            sFiles = Bst_BandPassFilter(sFiles, frequence, char(obj.SensorType));   
        end
        
        function sFiles = powerSpectrumDensity(obj, listOfParameters, sFiles)
            windowLength = listOfParameters.getConvertedValue(1);
            windowOverlap = listOfParameters.getConvertedValue(2);
            Bst_PowerSpectrumDensity(windowLength, windowOverlap, char(obj.SensorType), sFiles);  
        end
        
        function sFiles = detectCardiacArtifact(~, listOfParameters, sFiles)
            channelName = listOfParameters.getConvertedValue(1);
            eventName = listOfParameters.getConvertedValue(2);
            timeWindow = listOfParameters.getConvertedValue(3);            
            Bst_DetectCardiacArtifact(channelName, eventName, timeWindow, sFiles);                             
        end
        
        function sFiles = detectBlinkArtifact(~, listOfParameters, sFiles)
            channelName = listOfParameters.getConvertedValue(1);
            eventName = listOfParameters.getConvertedValue(2);
            timeWindow = listOfParameters.getConvertedValue(3);            
            Bst_DetectBlinkArtifact(channelName, eventName, timeWindow, sFiles);
        end
        
        function sFiles = detectOtherArtifact(obj, listOfParameters, sFiles)            
            lowFreq = listOfParameters.getConvertedValue(1);
            highFreq = listOfParameters.getConvertedValue(2);
            timeWindow = listOfParameters.getConvertedValue(3);
            Bst_DetectOtherArtifact(timeWindow, lowFreq, highFreq, char(obj.SensorType), sFiles);
        end
        
        function sFiles = importEventFromFile(~, sFiles, filePath, eventName)            
            bst_process('CallProcess', 'process_evt_import', sFiles, [], ...
                'evtfile', {filePath, 'ARRAY-TIMES'}, ...
                'evtname', eventName);            
        end
                
        function sFiles = renameEvent(~, sFiles, oldName, newName)            
            bst_process('CallProcess', 'process_evt_rename', sFiles, [], ...
                'src',  oldName, ...
                'dest', newName);
        end
        
        function sFiles = deleteEvent(~, sFiles, eventName)
            bst_process('CallProcess', 'process_evt_delete', sFiles, [], ...
                    'eventname', eventName);                
        end
        
        function sFiles = ica(obj, listOfParameters, sFiles)
            nbComponents = listOfParameters.getConvertedValue(1);
            sFiles = Bst_Ica(nbComponents, sFiles, char(obj.SensorType));
            ViewComponents(sFiles);            
        end
        
        function sFiles = exportToBids(~, listOfParameters, sFiles)
            be = BidsExporter();
            sFiles = be.export(listOfParameters, sFiles);            
        end
       
        function sFilesOut = importEvents(~, listOfParameters, sFilesIn)
            event = listOfParameters.getConvertedValue(1);
            epoch = listOfParameters.getConvertedValue(2);
            
            sFilesOut = cell(1, length(sFilesIn) + length(event));
            for i = 1:length(sFilesIn)           
                subject = sFilesIn(i).SubjectName;
                sFilesOut{i} = Bst_ImportEvent(subject, event, epoch, sFilesIn(i));
            end   
            sFilesOut = cell2mat(sFilesOut);
        end
        
        function sFilesOut = importTime(~, listOfParameters, sFilesIn)
            timeWindow = listOfParameters.getConvertedValue(1);
            if isscalar(timeWindow)
               timeWindow = [timeWindow SFileManager.getLengthOfRecording(sFilesIn)];
            end
            sFilesOut = cell(1, length(sFilesIn));
            for i = 1:length(sFilesIn)           
                sFilesOut{i} = Bst_ImportTime(sFilesIn(i), timeWindow);
            end   
            sFilesOut = cell2mat(sFilesOut);
        end
        
        function sFilesOut = importTimeBetweenEvent(~, listOfParameters, sFilesIn)
            eventName = listOfParameters.getConvertedValue(1);
            timeWindow = EventManager.getTimeOfEvent(sFilesIn, eventName);
            sFilesOut = Bst_ImportTime(sFilesIn, timeWindow);            
        end
        
        function sFiles = rejectBadTrials(~, listOfParameters, sFiles)
            
            sFiles = bst_process('CallProcess', 'process_detectbad', sFiles, [], ...
                'timewindow', listOfParameters.getConvertedValue(7), ...
                'meggrad',    listOfParameters.getConvertedValue(1), ...
                'megmag',     listOfParameters.getConvertedValue(2), ...
                'eeg',        listOfParameters.getConvertedValue(3), ...
                'ieeg',       listOfParameters.getConvertedValue(4), ...
                'eog',        listOfParameters.getConvertedValue(5), ...
                'ecg',        listOfParameters.getConvertedValue(6), ...
                'rejectmode', listOfParameters.getConvertedValue(8));  % Reject the entire trial
        end
        
        function sFiles = average(~, listOfParameters, sFiles)
            avgType = listOfParameters.getConvertedValue(1);
            avgFunction = listOfParameters.getConvertedValue(2);
            sFiles = Bst_Average(avgType, avgFunction, sFiles);
        end
       
        function sFiles = computeSources(~, listOfParameters, sFiles)
            toRun = listOfParameters.getConvertedValue(1);            
            if toRun
                sFiles = bst_process('CallProcess', 'process_inverse_2018', sFiles, [], ...
                                'output',  1, ...  % Kernel only: shared
                                'inverse', struct(...
                                 'NoiseCovMat',    [], ...
                                 'DataCovMat',     [], ...
                                 'ChannelTypes',   {{}}, ...
                                 'InverseMethod',  'minnorm', ...
                                 'InverseMeasure', 'amplitude', ...
                                 'SourceOrient',   {{'fixed'}}, ...
                                 'Loose',          0.2, ...
                                 'UseDepth',       1, ...
                                 'WeightExp',      0.5, ...
                                 'WeightLimit',    10, ...
                                 'NoiseMethod',    'reg', ...
                                 'NoiseReg',       0.1, ...
                                 'SnrMethod',      'fixed', ...
                                 'SnrRms',         1000, ...
                                 'SnrFixed',       3, ...
                                 'FunctionName',   []));
            end                             
        end
        
        function sFiles = exportData(~, listOfParameters, sFiles)            
            folder = listOfParameters.getConvertedValue(1);
            extension = listOfParameters.getConvertedValue(2);
            fileFormat = listOfParameters.getConvertedValue(3);
            
            for i = 1:length(sFiles)
                studyName = sFiles(i).Condition;
                channelFile = ChannelManager.getChannelFilePath(sFiles(i));
                path = convertStringsToChars(fullfile(folder, strcat(studyName, extension)));
                [~, sFiles] = export_data(sFiles(i).FileName, channelFile, path, fileFormat);
            end            
        end
        
    end
    
    methods (Static, Access = public)
        
        function obj = instance()           
            persistent uniqueInstance;            
            if isempty(uniqueInstance)
                obj = BstFunctions();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end            
        end
        
    end
    
end