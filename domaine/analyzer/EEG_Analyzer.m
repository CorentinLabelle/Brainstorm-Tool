classdef EEG_Analyzer < Analyzer
% Class that encapsulates the Brainstorm 
% functions for EEG data.
    
    properties (Constant, GetAccess = public)
        
        SensorType = "EEG";
        
    end
    
    methods (Access = public)
        
        function sFiles = addEegPosition(obj, sParameters, sFiles)
            
            eegParameters = obj.setAddEegParametersWithParameterStructure(sParameters);

            bst_process('CallProcess', 'process_channel_addloc', sFiles, [], ...
                        'channelfile', {eegParameters.electrode_file, eegParameters.file_format}, ...
                        'usedefault', eegParameters.cap_number, ...
                        'fixunits', 1, ...
                        'vox2ras', eegParameters.vox2ras);
                    
        end
        
        function sFiles = refineRegistration(~, sParameters, sFiles)
            
            toRun = sParameters.to_run;
            
            if toRun
                bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
            end
            
        end
        
        function sFiles = projectElectrodesOnScalp(~, sParameters, sFiles)
            
            toRun = sParameters.to_run;
            
            if toRun
                bst_process('CallProcess', 'process_channel_project', sFiles, []);
            end
            
           
        end
                               
        function sFiles = averageReference(obj, sParameters, sFiles)
            
            toRun = sParameters.to_run;
            
            if toRun
                 bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                        'eegref', 'AVERAGE', ...
                        'sensortypes', obj.SensorType);
            
                % Ask user to select components
                obj.viewComponents(sFiles);
            end
            
        end
        
    end
    
    methods (Static, Access = public)
        
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
    
    methods (Static, Access = private)
        
        function eegParameters = setAddEegParametersWithParameterStructure(sParameters)
           
            eegParameters = struct('electrode_file', char.empty, ...
                                    'file_format', char.empty, ...
                                    'vox2ras', double.empty, ...
                                    'cap_number', double.empty);
            
            fileType = sParameters.file_type;
            switch fileType
            
                case 'Use Default Pattern'
                    eegParameters.vox2ras = 1;
                    eegParameters.cap_number = EEG_Analyzer.getcapNumberWithCapName(sParameters.cap);

                case  'Import'
                    eegParameters.electrode_file = sParameters.electrode_file;
                    eegParameters.file_format = 'XENSOR';
                    eegParameters.cap_number = 1;
                    eegParameters.vox2ras = 0;
                    
                otherwise
                    error('FileType not supported for Add EEG Position');
                    
            end
            
        end
        
        function capNumber = getcapNumberWithCapName(capName)
           
            switch capName
                        
                case 'Colin27: BrainProducts EasyCap 128'
                    capNumber = 22;

                otherwise
                    capNumber = 0;
            end
            
        end
        
    end
    
end