classdef SensorType
    enumeration
        EEG, MEG
    end
    
    methods (Access = public)
       
        function analyzer = getAnalyzer(obj)
            processClass = obj.convertToProcessClass();
            analyzer = eval([char(processClass) '.getAnalyzer']);
        end
        
        function processClass = convertToProcessClass(obj)
            switch obj                
                case SensorType.EEG
                    processClass = ProcessClass.EegProcess;
                case SensorType.MEG         
                    processClass = ProcessClass.MegProcess;
                otherwise
                    error('InvalidType');                
            end
        end
        
    end
    
    methods (Static, Access = public)
        
        function sensorType = fromChar(characters)
            characters = lower(characters);
            switch characters
                case 'eeg'
                    sensorType = SensorType.EEG;
                case 'meg'
                    sensorType = SensorType.MEG;
                otherwise
                    error([ 'Invalid Type (' characters ').' newline ...
                            'Cannot convert characters to a sensor type.']);
            end
        end
        
        function sensorType = fromString(str)
            sensorType = SensorType.fromChar(char(str));
        end
        
    end
end