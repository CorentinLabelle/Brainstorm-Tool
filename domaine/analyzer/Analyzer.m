classdef Analyzer < handle & matlab.mixin.Heterogeneous

    methods (Access = public)
        
        function sFiles = createSubject(obj, sParameters, ~)
           
            anatomyPath = sParameters.anatomy_path;
            subjectName = sParameters.subject_name;
                                
            if isempty(anatomyPath) 
                db_add_subject(subjectName, [], 1, 0);
            else
                anatomyFileFormat = obj.getAnatomyFileFormat();
                obj.importAnatomy(subjectName, AnatomyPath, anatomyFileFormat);
            end
            
            sFiles = [];
            
        end
        
        function sFiles = importAnatomy(~, subjectName, anatomyPath, anatomyFileFormat)
            % Import subject's anatomy
            
            sFiles = bst_process('CallProcess', 'process_import_anatomy', [], [], ...
            'subjectname', subjectName, ...
            'mrifile', {anatomyPath, anatomyFileFormat}, ...
            'nvertices', 15000, ...
            'nas', [], ...
            'lpa', [], ...
            'rpa', [], ...
            'ac', [], ...
            'pc', [], ...
            'ih', []);
        
        end
        
        function sFiles = reviewRawFiles(~, sParameters, ~)
            % Review raw files
            
            subjects = sParameters.subjects;
            rawFilesPath = sParameters.raw_files;
                        
            sFiles = struct.empty();
            for i = 1:length(subjects)
                
                fileFormat = Analyzer.getFileFormatWithRawFilePath(rawFilesPath{i});
            
                sFiles{i} = bst_process('CallProcess', 'process_import_data_raw', [], [], ...
                    'subjectname',  subjects{i}, ...
                    'datafile',     {rawFilesPath{i}, fileFormat}, ...
                    'channelreplace', 1, ...
                    'channelalign', 0, ... % Align channel on MRI using fiducial points
                    'evtmode',     'value');
            
            end
                           
            sFiles = cell2mat(sFiles);
            
                
        end
         
        function sFiles = notchFilter(obj, sParameters, sFiles)
            % Apply notch filter
            
            frequence = sParameters.frequence;
            
            sFiles = bst_process('CallProcess', 'process_notch', sFiles, [], ...
                    'sensortypes', obj.SensorType, ...
                    'freqlist',    frequence, ...
                    'cutoffW',     1, ...
                    'useold',      0, ...
                    'read_all',    0);
                
        end
        
        function sFiles = bandPassFilter(obj, sParameters, sFiles)
            % Apply band-pass filter
            
            frequence = sParameters.frequence;
            
            sFiles = bst_process('CallProcess', 'process_bandpass', sFiles, [], ...
                'sensortypes', obj.SensorType, ...
                'highpass',    frequence(1), ...
                'lowpass',     frequence(2), ...
                'tranband',    0, ...
                'attenuation', 'strict', ...  % 60dB
                'ver',         '2019', ...  % 2019
                'mirror',      0, ...
                'read_all',    0);
            
        end
        
        function sFiles = powerSpectrumDensity(obj, sParameters, sFiles)
            % Generate power spectrum density (PSD)
            
            windowLength = sParameters.window_length;
            
            bst_process('CallProcess', 'process_psd', sFiles, [], ...
                'timewindow',  [], ...
                'win_length',  windowLength, ...
                'win_overlap', 50, ...
                'clusters',    {}, ...
                'sensortypes', obj.SensorType, ...
                'edit', struct(...
                    'Comment',    'Power', ...
                    'TimeBands',  [], ...
                    'Freqs',      [], ...
                    'ClusterFuncTime', 'none', ...
                    'Measure',    'power', ...
                    'Output',     'all', ...
                    'SaveKernel', 0));
            
        end
        
        function sFiles = detectCardiacArtifact(~, sParameters, sFiles)
            % Detect cardiac artifact
            
            channelName = sParameters.channel_name;
            eventName = sParameters.event_name;
            
            bst_process('CallProcess', 'process_evt_detect_ecg', sFiles, [], ...
                        'channelname', channelName, ...
                        'timewindow',  [], ...
                        'eventname',   eventName);                                
        end
        
        function sFiles = detectBlinkArtifact(~, sParameters, sFiles)
            % Detect blink artifact
            
            channelName = sParameters.channel_name;
            eventName = sParameters.event_name;
            
            bst_process('CallProcess', 'process_evt_detect_eog', sFiles, [], ...
                        'channelname', channelName, ...
                        'timewindow',  [], ...
                        'eventname',   eventName);
        end
        
        function sFiles = detectOtherArtifact(obj, sParameters, sFiles)
            % Detect low and/or high frequences artifact
                % Low frequences is usually for eyes and/or teeth
                % movements
                % High frequences is usually for muscular and/or sensor
                % movements
            
            LowFreq = sParameters.low_frequence;
            HighFreq = sParameters.high_frequence;
                
            bst_process('CallProcess', 'process_evt_detect_badsegment', sFiles, [], ...
                        'timewindow',  [], ...
                        'sensortypes', obj.SensorType, ...
                        'threshold',   3, ...
                        'isLowFreq',   LowFreq, ...   % 0 ou 1: detect eyes/teeth movements
                        'isHighFreq',  HighFreq);      % 0 ou 1: detect muscular/sensor artifacts

        end
        
        function sFiles = importEventFromFile(~, sFiles, filePath, eventName)
            % Import events from file
            
            bst_process('CallProcess', 'process_evt_import', sFiles, [], ...
                'evtfile', {filePath, 'ARRAY-TIMES'}, ...
                'evtname', eventName);
            
        end
                
        function sFiles = renameEvent(~, sFiles, oldName, newName)
            % Rename event
            
            bst_process('CallProcess', 'process_evt_rename', sFiles, [], ...
                'src',  oldName, ...
                'dest', newName);
            
        end
        
        function sFiles = deleteEvent(~, sFiles, eventName)
            % Delete event
            
            bst_process('CallProcess', 'process_evt_delete', sFiles, [], ...
                    'eventname', eventName);
                
        end
        
        function sFiles = ica(obj, sParameters, sFiles)
            % Compute independant component analysis (ICA) and asks user to
            % select components
            
            nbComponents = sParameters.number_of_components;
            
            bst_process('CallProcess', 'process_ica', sFiles, [], ...
                'timewindow', [], ...
                'eventname', '', ...
                'eventtime', [0, 0], ...
                'bandpass', [0, 0], ...
                'nicacomp', nbComponents, ...
                'sensortypes', obj.SensorType, ...
                'icasort',      '', ...
                'usessp', 1, ...
                'ignorebad', 1, ...
                'saveerp', 0, ...
                'method', 1, ...
                'select', []);

            % Ask user to select components
            obj.viewComponents(sFiles);
            
        end
        
        function viewComponents(~, sFiles)
            % Ask user to select components
            
            % Loop through sFiles
            for i = 1:length(sFiles)
                
                % Open timeseries
                timeseries = view_timeseries(sFiles(i).FileName);
                
                % Open ssp selection
                panel_ssp_selection('OpenRaw');
                
                % Wait for user to select components
                waitfor(msgbox("Click when you are done choosing. It will skip to the next study."));
                
                % Close timeseries
                close(timeseries);
            end
            
        end
        
        function sFiles = exportToBids(~, sParameters, sFiles)
            
            bidsFolder = sParameters.folder;
            
            bidsExporter = BidsExporter(sFiles, bidsFolder);
            sFiles = bidsExporter.export();
            
        end
       
        function sFilesOut = importEvents(~, sParameters, sFilesIn)
            % Import in database
            
            for i = 1:length(sFilesIn)
                
                subject = sFilesIn(i).SubjectName;
                
                sFilesOut(i) = bst_process('CallProcess', 'process_import_data_event', sFilesIn(i), [], ...
                'subjectname', subject, ...
                'condition',   '', ...
                'eventname',   sParameters.event, ...
                'timewindow',  [], ...
                'epochtime',   sParameters.epoch, ...
                'createcond',  1, ...
                 'ignoreshort', 1, ...
                 'usectfcomp',  1, ...
                 'usessp',      1, ...
                 'freq',        [], ...
                 'baseline',    []);
            end
         
        end
        
        function sFilesOut = importTime(~, sParameters, sFilesIn)
            
            for i = 1:length(sFilesIn)
                
                subject = sFilesIn(i).SubjectName;
                
                sFilesOut(i) = bst_process('CallProcess', 'process_import_data_time', sFilesIn(i), [], ...
                    'subjectname',   subject, ...
                    'condition',     '', ...
                    'timewindow',    sParameters.time_window, ...
                    'split',         0, ...
                    'ignoreshort',   1, ...
                    'usectfcomp',    1, ...
                    'usessp',        1, ...
                    'freq',          [], ...
                    'baseline',      [], ...
                    'blsensortypes', 'MEG, EEG');
            end

        end
        
        function sFiles = rejectBadTrials(~, sParameters, sFiles)
            % Reject bad trial
            
            sFiles = bst_process('CallProcess', 'process_detectbad', sFiles, [], ...
                'timewindow', [], ...
                'meggrad',    sParameters.MEGGrad, ...
                'megmag',     sParameters.MEGMag, ...
                'eeg',        sParameters.EEG, ...
                'ieeg',       sParameters.SEEG_ECOG, ...
                'eog',        sParameters.EOG, ...
                'ecg',        sParameters.ECG, ...
                'rejectmode', 2);  % Reject the entire trial
            
        end
        
        function sFiles = average(~, sParameters, sFiles)
            % Compute average
            
            sFiles = bst_process('CallProcess', 'process_average', sFiles, [], ...
                'avgtype',       sParameters.average_type, ...  % By folder (grand average)
                'avg_func',      sParameters.average_function, ...  % Average absolute values:  mean(abs(x))
                'weighted',      0, ...
                'keepevents',    0);

        end
       
        function sFiles = computeSources(~, sParameters, sFiles)
            % Compute sources
            
            toRun = sParameters.to_run;
            
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
        
        function sFiles = exportData(~, sParameters, sFiles)
            
            folder = sParameters.folder;
            extension = BstUtility.getExtensionFromFileFormat(sParameters.file_format);
            
            for i = 1:length(sFiles)

                % Get study name
                studyName = sFiles(i).Condition;
                
                % Get channel file
                channelFile = BstUtility.getChannelFilePath(sFiles(i));

                % Build path to exported study
                path = convertStringsToChars(...
                    fullfile(folder, strcat(studyName, extension)));

                % Export file
                [~, sFiles] = export_data(sFiles(i).FileName, channelFile, path, []);
    
            end
            
        end
       
    end
    
    methods (Static, Access = public)
        
        function obj = instance()
           
            persistent uniqueInstance;
            
            if isempty(uniqueInstance)
                obj = Analyzer();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
            
        end
        
        function fileFormat = getFileFormatWithRawFilePath(rawFilePath)
            
            [~, ~, extension] = fileparts(rawFilePath);
            if ischar(extension)
                extension = {extension};
            end

            switch char(unique(extension))
                case '.bin'
                    fileFormat = 'EEG-DELTAMED';

                case '.eeg'          
                    fileFormat = 'EEG-BRAINAMP';

                case '.edf'
                    fileFormat = 'EEG-EDF';

                case '.meg4'
                    fileFormat = 'CTF';
                    
                otherwise
                    error('Unsupported File Extension');
            end 

        end
       
    end
    
    methods (Access = private)
        
        function anatomyFileFormat = getAnatomyFileFormat(obj)
            switch obj.Type
                case 'EEG'
                    anatomyFileFormat = "FreeSurfer-fast";
                    
                case 'MEG'
                    anatomyFileFormat = "FreeSurfer";
            end
        end
        
    end
    
end