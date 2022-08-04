classdef PipelineBuilderManager
    
    properties (Access = private)
        
        App Pipeline_Builder
        
    end
    
    methods (Access = ?Pipeline_Builder)
        
        function obj = PipelineBuilderManager(app)
            
            obj.App = app;
            
        end
                
        function getEEGPipelineProcesses(obj)

            if (obj.App.EEGReviewRawFilesCheckBox.Value)
                
                [rawFilesPath, subjects] = obj.App.controller.getReviewRawFilesParameters();
                
                ReviewRawFiles.Subjects = rawFilesPath;
                ReviewRawFiles.Raw_Files = subjects;
                
                assert(~isempty(rawFilesPath), 'Raw Files is empty');
                assert(~isempty(subjects), 'Subjects is empty');
                obj.App.controller.addProcess('Review Raw Files', ReviewRawFiles);
            end
            
            if (obj.App.AddEEGPositionCheckBox.Value)
                AddEEGPosition = obj.AddEEGPositionParameters();

                obj.App.controller.addProcess('Add EEG Position', AddEEGPosition);
                
            end
            
            if (obj.App.RefineRegistrationCheckBox.Value)
                RefineRegistration = struct();
                RefineRegistration.To_Run = true;
                
                obj.App.controller.addProcess('Refine Registration', RefineRegistration);
            end
            
            if (obj.App.ProjectElectrodeonScalpCheckBox.Value)
                ProjectElectrodesOnScalp = struct();
                ProjectElectrodesOnScalp.To_Run = true;
                
                obj.App.controller.addProcess('Project Electrode On Scalp', ProjectElectrodesOnScalp);
            end
            
            if (obj.App.NotchFilterEEGCheckBox.Value)
                NotchFilter = struct();
                NotchFilter.Frequence = obj.getNotchFilterParameters;
                
                obj.App.controller.addProcess('Notch Filter', NotchFilter);
            end
            
            if (obj.App.BandPassFilterEEGCheckBox.Value)
                BandPassFilter = struct();
                BandPassFilter.Frequence = [obj.App.LowCutOffHzEditField.Value, obj.App.HighCutOffHzEditField.Value];
                
                obj.App.controller.addProcess('Band-Pass Filter', BandPassFilter);
            end
            
            if (obj.App.PowerSpectrumDensityEEGCheckBox.Value)
                PowerSpectrumDensity.Window_Length = 10;
                
                obj.App.controller.addProcess('Power Spectrum Density', PowerSpectrumDensity);
            end
            
            if (obj.App.AverageReferenceCheckBox.Value)
                AverageReference = struct();
                AverageReference.To_Run = true;
                
                obj.App.controller.addProcess('Average Reference', AverageReference);
            end
            
            if (obj.App.ICAEEGCheckBox.Value)
                ICA = struct();
                ICA.Number_Of_Components = obj.App.NumberofComponentsICAEditField.Value;
                
                obj.App.controller.addProcess('ICA', ICA);
            end
            
            if (obj.App.ConverttoBIDSEEGCheckBox.Value)
                ConvertToBids = struct();
                ConvertToBids.Folder = replace(fullfile(obj.App.BIDSFolderPathEditField.Value, ...
                            obj.App.BIDSFolderNameEditField.Value), '\', '/');

                
                obj.App.controller.addProcess('Export To BIDS', ConvertToBids);
            end
            
        end
        
        function sProcess = getMEGPipelineProcesses(obj)
            
            sProcess = struct();
            
            if (obj.App.ConvertEpochtoContinueCheckBox.Value)
                sProcess.ConvertEpochToContinue.ToRun = true;
            end
            
            if (obj.App.NotchFilterMEGCheckBox.Value)
                sProcess.NotchFilter = obj.App.NotchFilterStruct;
            end
            
            if (obj.App.BandPassFilterMEGCheckBox.Value)
                sProcess.BandPassFilter = obj.App.BandPassFilterStruct;
            end
            
            if (obj.App.PowerSpectrumDensityMEGCheckBox.Value)
                sProcess.PowerSpectrumDensity.ToRun = true;
                sProcess.PowerSpectrumDensity.WindowLength = 4;
            end
        
            if (obj.App.DetectArtifactCheckBox.Value)
                sProcess.DetectArtifact.toRun = true;
                
                if (obj.App.CardiacCheckBox.Value)
                    sProcess.DetectArtifact.Cardiac.Channel = 'ECG';
                    sProcess.DetectArtifact.Cardiac.EventName = 'cardiac';
                end
                
                if (obj.App.BlinkCheckBox.Value)
                    sProcess.DetectArtifact.Blink.Channel = 'VEOG';
                    sProcess.DetectArtifact.Blink.EventName = 'blink';
                end
                
                sProcess.DetectArtifact.Other.LowFrequence = 0;
                if (obj.App.LowFrequencyeyeteethCheckBox.Value)
                    sProcess.DetectArtifact.Other.LowFrequence = 1;
                end
                
                sProcess.DetectArtifact.Other.HighFrequence = 0;
                if (obj.App.HighFrequencymusclesensorCheckBox.Value)
                    sProcess.DetectArtifact.Other.HighFrequence = 1;
                end
            end
            
            if (obj.App.RemoveSimultaneousEventCheckBox.Value)
                sProcess.RemoveSimultaneousEvents.ToRun = true;
                sProcess.RemoveSimultaneousEvents.EventToRemove = obj.App.EventtoRemoveEditField.Value;
                sProcess.RemoveSimultaneousEvents.TargetEvent = obj.App.TargetEventEditField.Value;
            end
            
            if (obj.App.SSPCheckBox.Value)
                eventName = obj.App.EventNameSSPEditField.Value;
                
                if (eventName == "cardiac")
                    sProcess.SSP.Cardiac.ToRun = true;
                    sProcess.SSP.Cardiac.EventName = eventName;
            
                elseif (eventName == "blink")
                    sProcess.SSP.Blink.ToRun = true;
                    sProcess.SSP.Blink.EventName = eventName;
            
                else
                    sProcess.SSP.Generic.ToRun = true;
                    sProcess.SSP.Generic.EventName = eventName;
                end
                
            end
            
            if (obj.App.ICAMEGCheckBox.Value)
                sProcess.ICA = obj.App.ICAStruct;
            end
            
            if (obj.App.ConverttoBIDSMEGCheckBox.Value)
                sProcess.ConvertToBids = obj.App.ConvertToBidsStruct;
            end
            
        end
        
        function fillCheckBoxWithStructure(obj, pipeline)
            
            obj.App.PipelineNameEditField.Value = strcat(pipeline.Name, pipeline.Extension);
            obj.App.SaveinFolderEditField.Value = pipeline.Folder;
            
            for i = 1:length(pipeline.Processes)
                
                process = pipeline.Processes{i};
                
                switch process.Name 
                    
                    case 'review_raw_files'
                        obj.App.EEGReviewRawFilesCheckBox.Value = true;

                        obj.App.controller.setReviewRawFilesParameters(process.Parameters.subjects, process.Parameters.raw_files);

                        obj.App.ReviewRawFilesTextArea.Value = obj.App.controller.convertReviewRawFilesParametersToCharacters();
                
                    case 'add_eeg_position'
                        obj.App.AddEEGPositionCheckBox.Value = true;
                        fileType = process.Parameters.file_type;
                        cap = process.Parameters.cap;
                        
                        if isequal(fileType, 'Use Default Pattern')
                            cap = strrep(cap, ' ', '');
                            cap = strrep(cap, ':', '');
                            buttonName = strcat(cap, 'Button');
                            obj.App.(buttonName).Value = true;
                        end
                
                    case 'refine_registration'
                        obj.App.RefineRegistrationCheckBox.Value = true;

                              
                    case 'project_electrode_on_scalp'
                        obj.App.ProjectElectrodeonScalpCheckBox.Value = true;
                    
                    
                    case 'notch_filter'
                        obj.App.NotchFilterEEGCheckBox.Value = true;

                        frequences = process.Parameters.frequence;

                        if isequal(frequences, [50, 100, 150, 200])
                            obj.App.EuropeButton.Value = true;

                        elseif isequal(frequences, [60, 120, 180, 240])
                            obj.App.NorthAmericaButton.Value = true;

                        else
                           obj.App.SpecificFrequenceButton.Value = true;

                           obj.App.Frequence.Value = '';
                           for j = 1:length(frequences)
                                obj.App.Frequence.Value = strcat(obj.App.Frequence.Value, sprintf('%.0f', frequences(j)), ', ');
                           end
                           obj.App.Frequence.Value = obj.App.Frequence.Value{1}(1:end-1);
                        end
                    
                    case 'band_pass_filter'
                        obj.App.BandPassFilterEEGCheckBox.Value = true;
                        obj.App.LowCutOffHzEditField.Value = process.Parameters.frequence(1);
                        obj.App.HighCutOffHzEditField.Value = process.Parameters.frequence(2);
                    
                    
                    case 'power_spectrum_density'
                        obj.App.PowerSpectrumDensityEEGCheckBox.Value = true;
                        obj.App.WindowLengthEditField.Value = process.Parameters.window_length;
                        
                    
                    case 'average_reference'
                        obj.App.AverageReferenceCheckBox.Value = true;   
                    
                    
                    case 'ica'
                        obj.App.ICAEEGCheckBox.Value = true;
                        obj.App.NumberofComponentsICAEditField.Value = process.Parameters.number_of_components;
                
                    
                    case 'export_to_bids'
                        obj.App.ConverttoBIDSEEGCheckBox.Value = true;
                        folder = process.Parameters.folder;
                        [folderPath, folderName] = fileparts(folder);
                        obj.App.BIDSFolderPathEditField.Value = folderPath;
                        obj.App.BIDSFolderNameEditField.Value = folderName;
                
                end
            end
                
            obj.refreshVisibility;
            
        end
        
        function refreshVisibility(obj)
         
            appChildren = obj.App.PipelineBuilderUIFigure.Children;
            
            for i = 1:length(appChildren)
                
                if isa(appChildren(i), 'matlab.ui.container.Panel') && ...
                        any(strcmp(["EEG Processes", "MEG Processes"], appChildren(i).Title))
                  
                    panelChildren = appChildren(i).Children;
                    
                    for j = 1:length(panelChildren)
                
                        if isa(panelChildren(j), 'matlab.ui.control.CheckBox') && ~isempty(panelChildren(j).ValueChangedFcn)
                        
                            panelChildren(j).ValueChangedFcn(obj.App, []);
                            
                        end
                    end
                end
            end  
        end
        
        function param = getNotchFilterParameters(obj)
            
            % Get Notch Filter Parameters
            switch obj.App.NotchGroup.SelectedObject
                case obj.App.EuropeButton
                    param = [50, 100, 150, 200];
                    
                case obj.App.NorthAmericaButton
                    param = [60, 120, 180, 240];
                    
                case obj.App.SpecificFrequenceButton
                    % Assuming frequences are separated by commas
                    frequences = split(obj.App.Frequence.Value, ',');
                    nbFrequence = length(frequences);
                     
                    param = zeros(1, nbFrequence);
                    for i = 1:nbFrequence
                        param(i) = string(frequences{i});
                    end
            end
            
        end
                
        function AddEEGPosition = AddEEGPositionParameters(obj)
            
                AddEEGPosition = struct();
            
                AddEEGPosition.File_Type = obj.App.AddEEGPositionGroup.SelectedObject.Text;
                
                if strcmp(AddEEGPosition.File_Type, 'Use Default Pattern')
                    AddEEGPosition.Electrode_File = '';
                    
                elseif strcmp(AddEEGPosition.File_Type, 'Import File')
                    AddEEGPosition.Electrode_File = 'SomeFile.SomeExt';
                    
                end
    
                AddEEGPosition.Cap = obj.App.ChooseCapButtonGroup.SelectedObject.Text;
        end
    
    end
    
end