classdef EEG_Analyzer < Analyzer
    
    properties (Access = protected)
        
        SensorType = 'EEG';
        SupportedDatasetFormat = {'*.eeg', '*.bin', '*.edf'};
        
    end
    
    methods (Access = private)
        
        function obj = EEG_Analyzer()
        end
        
    end
    
    methods (Access = public)

        function extensions = getExtensionSupported(obj)
            extensions = obj.SupportedDatasetFormat;
        end
        
        function sFiles = addEegPosition(~, sFiles, fileType, cap, electrodeFile)
            
            switch fileType
            
                case 'Use Default Pattern'
                    electrodeFile = '';
                    fileFormat = '';
                    vox2ras = 1;
                    
                    switch cap
                        
                        case 'Colin27: BrainProducts EasyCap 128'
                            capNumber = 22;
                            
                        otherwise
                            capNumber = 0;
                    end

                case  'Import'
                    fileFormat = 'XENSOR';
                    capNumber = 1;
                    vox2ras = 0;
                    
            end

            bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
                        'channelfile', {electrodeFile, fileFormat}, ...
                        'usedefault', capNumber, ...
                        'fixunits', 1, ...
                        'vox2ras', vox2ras);                    
        end
        
        function sFiles = refineRegistration(~, sFiles)
            bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
        end
        
        function sFiles = projectElectrodesOnScalp(~, sFiles)
           bst_process('CallProcess', 'process_channel_project', sFiles, []); 
        end
       
        function sFiles = detectOtherArtifact(obj, sFiles, LowFreq, HighFreq) 
           detectOtherArtifact@Analyzer(obj, sFiles, obj.sensorType, LowFreq, HighFreq);
        end
        
        function sFiles = notchFilter(obj, sFiles, frequence)
            sFiles = notchFilter@Analyzer(obj, sFiles, obj.SensorType, frequence);
        end
        
        function sFiles = bandPassFilter(obj, sFiles, frequence)
            sFiles = bandPassFilter@Analyzer(obj, sFiles, obj.SensorType, frequence);
        end
        
        function sFiles = powerSpectrumDensity(obj, sFiles, windowLength)
            sFiles = powerSpectrumDensity@Analyzer(obj, sFiles, obj.SensorType, windowLength);
        end
        
        function sFiles = averageReference(obj, sFiles)
            bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                        'eegref', 'AVERAGE', ...
                        'sensortypes', obj.SensorType);

            viewComponents(obj, sFiles);
        end
        
        function sFiles = ica(obj, sFiles, nbComponents)
            ica@Analyzer(obj, sFiles, nbComponents, obj.SensorType);
        end
        
        function sFiles = reviewRawFiles(obj, subject_name, raw_files_path)
            
            [~, ~, extension] = cellfun(@fileparts, raw_files_path, 'UniformOutput', false);              
            extension = unique(extension);
            assert(length(extension) == 1);
            
            % Modify file format based on extension
            switch extension{1}
                case '.bin'
                    file_format = 'EEG-DELTAMED';
                    
                case '.eeg'          
                    % Data Colected with Brainvision
                    file_format = 'EEG-BRAINAMP';
                    
                case '.edf'
                    file_format = 'EEG-EDF';
                    
                otherwise
                    return
            end 
            
            % Review Raw Files
            sFiles = obj.reviewRawFiles@Analyzer(subject_name, raw_files_path, file_format, 0);
            
        end

        function sFiles = exportToBids(obj, sFiles, bidsFolder)
            
            arguments
                obj 
                sFiles struct {mustBeNonempty}
                bidsFolder char {mustBeNonempty}
            end
            
            % Create folder
            bidsFolder = obj.Util.createBidsFolder(bidsFolder);
            
            % Get Event Description structure
            eventStructure = obj.BstUtil.EventStructure();
            
            % Iterate through all studies
            for i = 1:length(sFiles)
                
                assert(obj.BstUtil.checkIfsFileIsRaw(sFiles(i)));
                %rawsFiles = obj.Util.getRawsFile(sFiles(i));

                % Convert study to BIDS
                exportToBids@Analyzer(obj, sFiles(i), bidsFolder);
                
                % Get Path for TSV, JSON and PROVENANCE files.
                [rawPath, ~] =  obj.BstUtil.getBIDSpath(sFiles(i), bidsFolder, obj.SensorType);
                
                % Create .tsv file (Events)
                obj.BstUtil.create_Event_File(sFiles(i), [rawPath '_events.tsv']);
        
                % Create Json event description file
                obj.BstUtil.create_Event_MetaData_File(sFiles(i), [rawPath '_events.json'], eventStructure);
                
                % Create provenance file
                %obj.BstUtil.create_Provenance_File(sFiles(i), [derivative '_provenance.json']);
        
                % Create channel file
                obj.BstUtil.create_Channel_File(sFiles(i), [rawPath '_channels.tsv']);
                
                % Create electrode file
                obj.BstUtil.create_Electrode_File(sFiles(i), [rawPath '_electrodes.tsv']);
                
                % Create coordinate system file
                obj.BstUtil.createCoordonateSystemFile(sFiles(i), [rawPath '_coordsystem.json']);

            end
            
        end
        
    end
    
    methods(Static)
        
        function obj = instance()
           
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                obj = EEG_Analyzer();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
    end
    
end

