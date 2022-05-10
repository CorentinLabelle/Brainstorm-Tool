classdef MEG_Analyzer < Analyzer
    
    properties
        sensorType = 'MEG';
    end
    
    methods (Access = private)
        function obj = MEG_Analyzer()
        end
        
    end
    
    methods (Access = public)
        
        function sFiles = convertEpochsToContinue(~, sFiles)
            sFiles = bst_process('CallProcess', 'process_ctf_convert', sFiles, [], ...
                                'rectype', 2);
        end
        
        function sFiles = detectOtherArtifact(obj, sFiles, LowFreq, HighFreq) 
           detectOtherArtifact@BasicBstFunctions(obj, sFiles, obj.sensorType, LowFreq, HighFreq);
        end
        
        function sFiles = notchFilter(obj, sFiles, frequence)
            sFiles = notchFilter@BasicBstFunctions(obj, sFiles, obj.sensorType, frequence);
        end
        
        function sFiles = bandPassFilter(obj, sFiles, frequence)
            sFiles = bandPassFilter@BasicBstFunctions(obj, sFiles, obj.sensorType, frequence);
        end
        
        function sFiles = powerSpectrumDensity(obj, sFiles)
            powerSpectrumDensity@BasicBstFunctions(obj, sFiles, obj.sensorType, 4);
        end
        
        function sFiles = removeSimultaneaousEvents(~, sFiles, eventToRemove, eventToTarget)
            bst_process('CallProcess', 'process_evt_remove_simult', sFiles, [], ...
                        'remove', eventToRemove, ...
                        'target', eventToTarget, ...
                        'dt',     0.25, ...
                        'rename', 0);
        end
        
        function sFiles = sspCardiac(obj, sFiles)
            bst_process('CallProcess', 'process_ssp_ecg', sFiles, [], ...
                        'eventname',   'cardiac', ...
                        'sensortypes', obj.sensorType, ...
                        'usessp',      1, ...
                        'select',      1);
        
            viewComponents(obj, sFiles);
        end
        
        function sFiles = sspBlink(obj, sFiles)
           bst_process('CallProcess', 'process_ssp_eog', sFiles, [], ...
                        'eventname',   'blink', ...
                        'sensortypes', obj.sensorType, ...
                        'usessp',      1, ...
                        'select',      1);
                    
            viewComponents(obj, sFiles);
        end
        
        function sFiles = sspGeneric(obj, sFiles, eventName)
            bst_process('CallProcess', 'process_ssp', sFiles, [], ...
            'timewindow',  [], ...
            'eventname',   eventName, ...
            'eventtime',   [-0.2, 0.2], ...
            'bandpass',    [1.5, 15], ...
            'sensortypes', '', ...
            'usessp',      1, ...
            'saveerp',     0, ...
            'method',      1, ...  % PCA: One component per sensor
            'select',      1);
        
            viewComponents(obj, sFiles);
        
        end
        
        function sFiles = ica(obj, sFiles, nbComponents)
            ica@BasicBstFunctions(obj, sFiles, nbComponents, obj.sensorType);
        end
    end
    
    methods(Static)
        
        function obj = instance()
           
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                obj = MEG_Analysis();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
    end    
end

