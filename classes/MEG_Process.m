classdef MEG_Process < Process

    properties (Access = public)
        
        Analyzer = MEG_Analysis();
        Type = 'MEG';
        
    end
    
    
    methods (Access = public)
        
         function obj = MEG_Process(name, parameters)
             
            assert(1 > 0, 'You need at least the name to create a Process');
            
            obj.Date = Utility.get_Time_Now();
            obj.Name = name;
            %obj.initialization();
            
            if nargin == 2
                obj.Parameters = parameters;
            end
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

