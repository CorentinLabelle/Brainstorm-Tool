classdef EEG_Analysis < Basic_Analysis
    
    properties (Access = public)
        
        Sensor_Type = 'EEG';
        Extension_In_Supported = {'*.eeg'; '*.bin'};
        
    end
    
    methods (Access = public)
        
        function obj = EEG_Analysis()
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
           detectOtherArtifact@Basic_Analysis(obj, sFiles, obj.sensorType, LowFreq, HighFreq);
        end
        
        function sFiles = notchFilter(obj, sFiles, frequence)
            sFiles = notchFilter@Basic_Analysis(obj, sFiles, obj.Sensor_Type, frequence);
        end
        
        function sFiles = bandPassFilter(obj, sFiles, frequence)
            sFiles = bandPassFilter@Basic_Analysis(obj, sFiles, obj.Sensor_Type, frequence);
        end
        
        function sFiles = powerSpectrumDensity(obj, sFiles)
            powerSpectrumDensity@Basic_Analysis(obj, sFiles, obj.Sensor_Type, 10);
        end
        
        function sFiles = averageReference(obj, sFiles)
            bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                        'eegref', 'AVERAGE', ...
                        'sensortypes', obj.Sensor_Type);

            viewComponents(obj, sFiles);
        end
        
        function sFiles = ica(obj, sFiles, nbComponents)
            ica@Basic_Analysis(obj, sFiles, nbComponents, obj.Sensor_Type);
        end
        

        % To improve
        function sFiles = reviewRawFiles(obj, subject_name, raw_files_path, extension)
                                  
            % Modify file format based on extension
            switch extension
                case '.bin'
                    file_format = 'EEG-DELTAMED';
                    %funct = 'get_Date_From_VMRK';
                    
                case '.eeg'          
                    % Data Colected with Brainvision
                    file_format = 'EEG-BRAINAMP';
                    %funct = 'getDateFromVMRK';
                    
                case '.edf'
                    file_format = 'EEG-EDF';
                    %funct = 'getDateFromEDF';
                    
                otherwise
                    return
            end 
            
            % Review Raw Files
            sFiles = obj.reviewRawFiles@Basic_Analysis(subject_name, raw_files_path, file_format, 0);

%             recording_Date = obj.Util.(funct)(raw_files_path);

%             if ischar(recording_Date)
%                 recording_Date = {recording_Date};
%             end

%             % Modify Date of new Study in brainstormstudy.mat
%             obj.Util.modifyBrainstormStudyMATDate(sFiles, recording_Date);
            
        end
        
        function sFiles = convertToBids(obj, sFiles, bidsFolder, dataFileFormat)
            
            arguments
                obj EEG_Analysis
                sFiles struct {mustBeNonempty}
                bidsFolder char {mustBeNonempty}
                dataFileFormat char = 'BrainVision';
            end
            
            %% Create folder
            nb_folder = 0;
            while isfolder(bidsFolder)
                nb_folder = nb_folder + 1;
                if nb_folder ~= 1
                    bidsFolder = bidsFolder(1:find(bidsFolder == '_', 1, 'last')-1);
                end
                bidsFolder = strcat(bidsFolder, '_', num2str(nb_folder));
            end
            mkdir(bidsFolder);
            
            %% Get Event Description structure    
            eventStructure = obj.Util.EventStructure();
            
            %% Iterate through all studies
            for i = 1:length(sFiles)
                
                rawsFiles = obj.Util.getRawsFile(sFiles(i));
                
                switch dataFileFormat
                    case 'BrainVision'
                        convertToBids@Basic_Analysis(obj, rawsFiles, bidsFolder);
                        
                    case 'EDF'
                        % Export study to EDF
                        %edf_file = obj.Util.exportToEDF(rawsFiles, pwd);
                        edf_file = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/Science_Advances_2022/@rawactives_electrodes_visual_stim_s1_07.edf';
                            
                        % Reimport EDF file in Brainstorm      
                        sFilesEDF = obj.reviewRawFiles(sFiles(i).SubjectName, ...
                           edf_file, '.edf');

                        % Convert EDF study to BIDS
                        convertToBids@Basic_Analysis(obj, sFilesEDF, bidsFolder);
                
                        % Delete EDF study that was 're-imported'.
                        bst_process('CallProcess', 'process_delete', sFilesEDF, [], ...
                        'target', 2); % 1: fichier 2: folder 3: subjects

                        %delete(edf_file);
                        
                        rawsFiles = sFilesEDF;
                end

                
                
        
                % Get Path for TSV, JSON and PROVENANCE files.
                [event_path, meta_event_path, provenance_path, electrode_path, coord_path] = ...
                    obj.Util.getBIDSpath(rawsFiles, bidsFolder, obj.Sensor_Type);
                
                % Create .tsv file (Events)
                obj.Util.create_Event_File(rawsFiles, event_path);
        
                % Create Json event description file
                obj.Util.create_Event_MetaData_File(rawsFiles, meta_event_path, eventStructure);
        
                % Create provenance file
                obj.Util.create_Provenance_File(rawsFiles, provenance_path);
        
                % Create electrode file
                obj.Util.create_Electrode_File(rawsFiles, electrode_path);
                
                % Create coordinate system file
                obj.Util.createCoordonateSystemFile(rawsFiles, coord_path);

            end
            
        end
        
    end
    
end

