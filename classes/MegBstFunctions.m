classdef MegBstFunctions < BasicBstFunctions
    properties
        sensorType = 'MEG';
    end
    
    methods
        function obj = MegBstFunctions()
        end
        
        function sFiles = convertEpochsToContinue(~, sFiles)
            sFiles = bst_process('CallProcess', 'process_ctf_convert', sFiles, [], ...
                                'rectype', 2);
        end
        
        function detectOtherArtifact(obj, sFiles, LowFreq, HighFreq) 
           detectOtherArtifact@BasicBstFunctions(obj, sFiles, obj.sensorType, LowFreq, HighFreq);
        end
        
        function sFiles = notchFilter(obj, sFiles, frequence)
            sFiles = notchFilter@BasicBstFunctions(obj, sFiles, obj.sensorType, frequence);
        end
        
        function sFiles = bandPassFilter(obj, sFiles, frequence)
            sFiles = bandPassFilter@BasicBstFunctions(obj, sFiles, obj.sensorType, frequence);
        end
        
        function powerSpectrumDensity(obj, sFiles)
            powerSpectrumDensity@BasicBstFunctions(obj, sFiles, obj.sensorType, 4);
        end
        
        function removeSimultaneaousEvents(~, sFiles, eventToRemove, eventToTarget)
            bst_process('CallProcess', 'process_evt_remove_simult', sFiles, [], ...
                        'remove', eventToRemove, ...
                        'target', eventToTarget, ...
                        'dt',     0.25, ...
                        'rename', 0);
        end
        
        function sspCardiac(obj, sFiles)
            bst_process('CallProcess', 'process_ssp_ecg', sFiles, [], ...
                        'eventname',   'cardiac', ...
                        'sensortypes', obj.sensorType, ...
                        'usessp',      1, ...
                        'select',      1);
        
            viewComponents(obj, sFiles);
        end
        
        function sspBlink(obj, sFiles)
           bst_process('CallProcess', 'process_ssp_eog', sFiles, [], ...
                        'eventname',   'blink', ...
                        'sensortypes', obj.sensorType, ...
                        'usessp',      1, ...
                        'select',      1);
                    
            viewComponents(obj, sFiles);
        end
        
        function sspGeneric(obj, sFiles, eventName)
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
        
        function ica(obj, sFiles, nbComponents)
            ica@BasicBstFunctions(obj, sFiles, nbComponents, obj.sensorType);
        end
    end
end

