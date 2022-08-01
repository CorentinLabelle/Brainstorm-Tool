classdef MEG_Analyzer < Analyzer
% Class that encapsulates the Brainstorm 
% functions for MEG data.
    
    properties (Constant, GetAccess = public)

        SensorType = "MEG";

    end
    
    methods (Access = public)
        
        function sFiles = convertEpochsToContinue(~, sParameters, sFiles)
            
            toRun = sParameters.to_run;
            
            if toRun
                sFiles = bst_process('CallProcess', 'process_ctf_convert', sFiles, [], ...
                                'rectype', 2);
            end
            
        end
                      
        function sFiles = removeSimultaneaousEvents(~, sParameters, sFiles)
            
            eventToRemove = sParameters.event_to_remove;
            eventToTarget = sParameters.event_to_target;
            
            bst_process('CallProcess', 'process_evt_remove_simult', sFiles, [], ...
                        'remove', eventToRemove, ...
                        'target', eventToTarget, ...
                        'dt',     0.25, ...
                        'rename', 0);
        end
        
        function sFiles = sspCardiac(obj, sParameters, sFiles)
            
            eventName = sParameters.event;
            
            bst_process('CallProcess', 'process_ssp_ecg', sFiles, [], ...
                        'eventname',   eventName, ...
                        'sensortypes', obj.sensorType, ...
                        'usessp',      1, ...
                        'select',      1);
        
            viewComponents(obj, sFiles);
        end
        
        function sFiles = sspBlink(obj, sParameters, sFiles)
           
            eventName = sParameters.event;
            
            bst_process('CallProcess', 'process_ssp_eog', sFiles, [], ...
                        'eventname',   eventName, ...
                        'sensortypes', obj.sensorType, ...
                        'usessp',      1, ...
                        'select',      1);
                    
            viewComponents(obj, sFiles);
        end
        
        function sFiles = sspGeneric(obj, sParameters, sFiles)
            
            eventName = sParameters.event;
            
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
                
    end
    
    methods (Static, Access = public)
        
        function obj = instance()
           
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                obj = MEG_Analyzer();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
        
    end
    
end