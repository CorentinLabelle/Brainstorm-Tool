classdef PipelineValidator < Validator
        
    methods (Access = ?Pipeline)
        
        function obj = PipelineValidator()
        end
        
        function verifyPosition(obj, pipelineToValidate, position)
        % Verifies if the position is valid.
        %
        % INPUT
        %       position [int64]: must be non-empty.
        %
        % USAGE
        %       obj.verifyPosition(P)
            
            arguments
               obj
               pipelineToValidate Pipeline
               position int64 {mustBeNonempty}
            end
            
            eID = 'InvalidIndex';
                
            if any(position < 0)
                eMsg = 'Negative Index.';
                throw(obj.createException(eID, eMsg));
            end
                        
            greatestValidIndex = obj.getGreatestValidIndex(pipelineToValidate);
            if any(position > greatestValidIndex)
                eMsg = ['Index greater than ' num2str(greatestValidIndex) '.'];
                throw(obj.createException(eID, eMsg));
            end
            
        end
        
        function verifyIfProcessIsDuplicate(obj, pipelineToValidate, process)
           
            if pipelineToValidate.isProcessesInPipeline(process)
                eID = 'DuplicateProcess';
                eMsg = 'You are adding a process that is already in this pipeline.';
                throw(obj.createException(eID, eMsg));
            end
            
        end
        
        function verifyHistoryIsNotEmpty(obj, pipelineToValidate)
            
            if isempty(pipelineToValidate.History)
                eID = 'HistoryIsEmpty';
                eMsg = ['Cannot access previous pipeline because the history' ...
                        'is empty.'];
                throw(obj.createException(eID, eMsg));
            end
            
        end
        
        function verifyTypeOfProcesses(obj, processes)
            
            cls = cellfun(@(x) class(x), processes, 'UniformOutput', false);

            isEEG = any(contains(cls, 'EEG_Process'));
            isMEG = any(contains(cls, 'MEG_Process'));
            
            if isEEG && isMEG
                eID = 'InvalidProcessType';
                eMsg = 'You cannot have an EEG and MEG Process in the same pipeline';
                throw(obj.createException(eID, eMsg));
            end
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function isValid = validate(pipelineToValidate)
            
            isValid = true;
            
            if ~PipelineValidator.isValidName(pipelineToValidate)
                isValid = false;
                return
            end
                
            if PipelineValidator.validateProcesses(pipelineToValidate)
                isValid = false;
                return
            end
            
        end
        
        function isValid = validateProcesses(pipelineToValidate)
           
            isValid = true;
            
            if ~PipelineValidator.isValidProcesses(pipelineToValidate)
                isValid = false;
                return
            end
            
        end
        
        function isValid = isValidName(pipelineToValidate)
            
            isValid = true;
            
            propertyName = 'Name';
            nameDefaultValue = findprop(pipelineToValidate, propertyName).DefaultValue;
            
            if nameDefaultValue == pipelineToValidate.(propertyName)
                isValid = false;
                return
            end
            
        end
        
        function isValid = isValidFolder(pipelineToValidate)
            
            isValid = true;
            
            propertyName = 'Folder';
            folderDefaultValue = findprop(pipelineToValidate, propertyName).DefaultValue;
            
            if folderDefaultValue == pipelineToValidate.(propertyName)
                isValid = false;
                return
            end
            
            if ~isfolder(obj.pipelineToValidate.(propertyName))
                isValid = false;
                return
            end
            
        end
        
        function isValid = isValidExtension(pipelineToValidate)
            
            isValid = true;
            
            propertyName = 'Extension';
            extensionDefaultValue = findprop(pipelineToValidate, propertyName).DefaultValue;
            
            if extensionDefaultValue == pipelineToValidate.(propertyName)
                isValid = false;
                return
            end
            
            if ~any(pipelineToValidate.(propertyName) == Pipeline.getSupportedExtension)
                isValid = false;
                return
            end
            
        end
        
        function isValid = isValidProcesses(pipelineToValidate)
           
            isValid = true;
            
            if isempty(pipelineToValidate.Processes)
                isValid = false;
                return
            end
            
            if pipelineToValidate.isEEG
               
                addEegPositionIndex = pipelineToValidate.getProcessIndexWithName('add_eeg_position');
                if addEegPositionIndex <= 0
                    isValid = false;
                end
               
            elseif pipelineToValidate.isMEG
                
                convertEpToContIndex = pip.getProcessIndexWithName('Convert Epochs To Continue');
                if convertEpToContIndex <= 0
                    isValid = false;
                end
                
            end
            
            % AJOUTER
            % pre-processing avant l'importation
            
        end
        
        function isValid = checkNotchIsBeforeImportation(pipelineToValidate)
           
            notchFilterPosition = pipelineToValidate.search('Notch Filter');
            importationPosition = pipelineToValidate.search('Import');
            
            if (notchFilterPosition ~= -1 && importationPosition ~= -1)
                isValid = notchFilterPosition < importationPosition;
            else
                isValid = true;
            end
            
        end
        
        function isValid = checkBandPassIsBeforeImportation(pipelineToValidate)
           
            notchFilterPosition = pipelineToValidate.search('Band-Pass Filter');
            importationPosition = pipelineToValidate.search('Import');
            
            if (notchFilterPosition ~= -1 && importationPosition ~= -1)
                isValid = notchFilterPosition < importationPosition;
            else
                isValid = true;
            end
            
        end
        
        function isValid = checkBandPassIsBeforeIca(pipelineToValidate)
           
            notchFilterPosition = pipelineToValidate.search('Band-Pass Filter');
            icaPosition = pipelineToValidate.search('ICA');
            
            if (notchFilterPosition ~= -1 && icaPosition ~= -1)
                isValid = notchFilterPosition < icaPosition;
            else
                isValid = true;
            end
            
        end
        
        function isValid = checkNotchIsBeforeBandPass(pipelineToValidate)
           
            notchFilterPosition = pipelineToValidate.search('Notch Filter');
            bandPassPosition = pipelineToValidate.search('Band-Pass Filter');
            
            if (notchFilterPosition ~= -1 && bandPassPosition ~= -1)
                isValid = notchFilterPosition < bandPassPosition;
            else
                isValid = true;
            end
            
        end
        
        function greatestValidIndex = getGreatestValidIndex(pipelineToValidate)
            
            greatestValidIndex = length(pipelineToValidate.Processes);
            
            callingStack = dbstack;
            callerFcts = string({callingStack(:).name});
            if any(strcmpi(callerFcts, 'Pipeline.addProcess'))
                greatestValidIndex = greatestValidIndex + 1;
            end
            
        end
        
    end
    
end

