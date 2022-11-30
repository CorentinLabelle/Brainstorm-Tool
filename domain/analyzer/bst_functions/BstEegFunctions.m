classdef BstEegFunctions < BstFunctions
    
    properties (Constant, GetAccess = public)
        SensorType = SensorType.EEG;
    end
    
    methods (Access = public)
        
        function sFiles = addEegPosition(~, listOfParameters, sFiles)
            electrodeFile = listOfParameters.getConvertedValue(1);
            fileFormat = listOfParameters.getConvertedValue(2);
            capNumber = listOfParameters.getConvertedValue(3);
            
            if isempty(electrodeFile)
                vox2ras = 1;
            else
                vox2ras = 0;
            end            
            Bst_AddEegPosition(electrodeFile, fileFormat, capNumber, vox2ras, sFiles);
        end
        
        function sFiles = refineRegistration(~, listOfParameters, sFiles)
            toRun = listOfParameters.getConvertedValue(1);
            if toRun
                bst_process('CallProcess', 'process_headpoints_refine', sFiles, []);
            end
        end
        
        function sFiles = projectElectrodesOnScalp(~, listOfParameters, sFiles)
            toRun = listOfParameters.getConvertedValue(1);
            if toRun
                bst_process('CallProcess', 'process_channel_project', sFiles, []);
            end
        end
                               
        function sFiles = averageReference(obj, listOfParameters, sFiles)
            eegReference = listOfParameters.getConvertedValue(1);
            sFiles = bst_process('CallProcess', 'process_eegref', sFiles, [], ...
                    'eegref', eegReference, ...
                    'sensortypes', char(obj.SensorType));
            %ViewComponents(sFiles);
        end
        
    end
    
    methods (Static, Access = public)
        
        function obj = instance()            
            persistent uniqueInstance;            
            if isempty(uniqueInstance)
                obj = BstEegFunctions();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end            
        end
        
    end

end