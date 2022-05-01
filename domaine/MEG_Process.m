classdef MEG_Process < Process

    properties (Access = protected)
        
        Analyzer = MEG_Analysis.instance();
        Type = 'MEG';
        SpecificProcesses = [];
        
    end
    
    
    methods (Access = public)
        
        function obj = MEG_Process(nameOrStruct)
            obj@Process(nameOrStruct);
        end
        
        
        function sFiles = run_Process(obj, sFiles)
            
            name = obj.fName;
            parameters = obj.Parameters;
            
            switch name 
                
                case 'process_import_data_raw'
                    for i = 1:size(parameters.Subject_Data, 1)
                        sFiles = obj.Analyzer.review_Raw_Files(...
                            parameters.Subject_Data{i, 1}, ...
                            parameters.Subject_Data{i, 2}, ...
                            parameters.Subject_Data{i, 3});
                    end
                            
                case 'process_notch'
                    sFiles = obj.Analyzer.notchFilter(sFiles, parameters.Frequence);
            
                case 'process_bandpass'
                    sFiles = obj.Analyzer.bandPassFilter(sFiles, parameters.Frequence);
            
                case 'process_psd'
                    obj.Analyzer.powerSpectrumDensity(sFiles);
            
                case 'process_ica'
                    obj.Analyzer.ica(sFiles, parameters.NumberOfComponents);
            
                case 'process_export_bids'
                    obj.Analyzer.convert_To_Bids(sFiles, parameters.BIDSpath);
            end
            
            obj.add_Process_To_History();
            
        end
         
    end
    
    methods (Access = protected)
        
        function sProcess = get_sProcess(obj)
            
            switch obj.fName 
                
                case 'process_import_data_raw'
                    obj.Name = 'Review_Raw_Files';
                            
                case 'process_notch'
                    obj.Name = 'Notch_Filter';
            
                case 'process_bandpass'
                    obj.Name = 'Bandpass_Filter';
            
                case 'process_psd'
                    obj.Name = 'Power_Spectrum_Density';
            
                case 'process_ica'
                    obj.Name = 'ICA';
            
                case 'process_export_bids'
                    obj.Name = 'Export_To_BIDS';
            end 
            
            sProcess = panel_process_select('GetProcess', obj.fName);
        end
 
    end
    
end

