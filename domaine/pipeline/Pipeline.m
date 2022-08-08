classdef Pipeline < handle & matlab.mixin.Copyable
% Handle class that implements the concept of Pipeline.
    
    properties (Dependent, GetAccess = public)
        
        % Pipeline's type
        % Dependent property
        % [string]: Possible types of pipeline are EEG or MEG.
        Type (1,1) string;
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        
        % Pipeline's name
        % [string]
        Name (1,1) string = strings(1,1);
        
        % Pipeline's folder
        % [string]
        Folder (1,1) string = strings(1,1);
        
        % Pipeline's extension
        % [string]: Possible extensions are .mat or .json.
        Extension string = string.empty;
        
        % Pipeline's date of creation
        % [datetime]
        DateOfCreation datetime = datetime;
        
        % Pipeline's processes
        % [Process]
        Processes cell = cell.empty();%Process = Process.empty;
        
        % Pipeline's documentation
        % [char]
        Documentation char = char.empty;
        
        % Pipeline's history
        % [cell]: {callerFuntionName, datetime, currentPipeline, Parameters}
        History struct = struct('Function', {}, ...
                                'Datetime', {}, ...
                                'Parameters', {}, ...
                                'PipelineCopy', {});
        
    end
        
    properties (Constant, GetAccess = private)
        
        % Pipeline's supported extensions
        % [string]: Default value = [".mat", ".json"]. 
        SupportedExtension = [".mat", ".json"];
        
        % Pipeline's Brainstorm Version
        % [struct]
        BrainstormVersion = bst_get('Version');
              
    end
    
    methods (Access = public)
        
        function obj = Pipeline(input)
        % Constructor of class Pipeline
        % The constructor take 0 or 1 argument. The argument can be a structure, a path to a file or the name of the pipeline.
        %
        %   INPUT
        %       input [char/string/struct]: optionnal
        %
        %   OUTPUT
        %       obj [Pipeline]: instance of Pipeline
        %
        %   USAGE
        %       obj = Pipeline()
        %       obj = Pipeline(input)
            
            if nargin == 0
                return
            end
            
            if isstruct(input)
                obj.convertStructureToPipeline(input);
                
            elseif isfile(input)
                obj.constructorWithFile(input);
                
            % Else, assume input is a file name
            else
                obj.setFile(input);
                
            end
            
        end
                           
        function setFile(obj, file)
        % Assigns folder, file name and extension to pipeline
        %
        %   INPUT
        %       file [string]: must be non-empty
        %
        %   USAGE
        %       obj.setFile(F)
            
            arguments
                obj Pipeline
                file (1,1) string {mustBeNonempty}
            end
            
            [folder, name, extension] = fileparts(file);
            
            if ~isequal(name, "")
                obj.Name = name;
            end
            
            if ~isequal(extension, "")
                obj.Extension = extension;
            end
            
            if ~isequal(folder, "")
                obj.Folder = folder;
            end
            
        end
        
        function setFolder(obj, folder)
        % Assigns folder to pipeline
        %
        %   INPUT
        %       folder [string]: optionnal
        %
        %   USAGE
        %       obj.setFolder() asks user to select folder F and assigns F to pipeline's Folder property
        %       obj.setFolder(F) assigns F to pipeline's Folder property
            
            arguments
                obj Pipeline
                folder (1,1) string = strings(1,1);
            end
            
            if isequal(folder, "")
                folder = uigetdir(pwd, 'Select the folder where to save your pipeline!');
                if folder == 0
                    return
                end
            end            
            
            obj.Folder = folder;
            
        end
        
        function setExtension(obj, extension)
        % Assigns extension to pipeline
        %
        %   INPUT
        %       extension [string]: must be non-empty
        %
        %   USAGE
        %       obj.setExtension(E): Assigns E to pipeline's Extension property
            
            obj.Extension = extension;
            
        end
        
        function addExtension(obj, extension)
            
            arguments
                obj Pipeline
                extension string {mustBeNonempty}
            end
            
            if isempty(obj.Extension)
                extensionToSet = extension;
            else
                extensionToSet = [obj.Extension extension];
            end
            
            obj.Extension = extensionToSet;
            
        end
        
        function rmExtension(obj, extensionsToRemove)
           
            arguments
                obj Pipeline
                extensionsToRemove string {mustBeNonempty}
            end
            
            extensionsToRemove = Pipeline.formatExtensionsWithLowerCaseAndDot(extensionsToRemove);
           
            extensionToSet = obj.Extension;
            for i = 1:length(extensionsToRemove)
                extensionToSet = extensionToSet(extensionToSet ~= extensionsToRemove(i));
            end
            
            obj.Extension = extensionToSet;
            
        end
        
        function setName(obj, name)
        % Assigns name to pipeline.
        %
        %   INPUT
        %       name [string]: must be non-empty.
        %
        %   USAGE
        %       obj.setName(N): Assigns N to pipeline's Name property.
          
            arguments
                obj Pipeline
                name (1,1) string {mustBeNonempty}
            end
            
            obj.Name = name;
            
        end
        
        function setDocumentation(obj, documentation)
        % Assigns documentation to pipeline.
        %
        %   INPUT
        %       documentation [char]
        %
        %   USAGE
        %       obj.setDocumentation(D): Assigns D to pipeline's Documentation property.
            
            arguments
                obj Pipeline
                documentation char
            end
            
            obj.Documentation = documentation;
            
        end
        
        function addProcess(obj, processToAdd, position)
        % Adds process to pipeline.
        %
        % INPUT
        %       process [Process]: must be non-empty.
        %       position [int64]: default value = last position
        %
        % USAGE
        %       obj.addProcess(PR): Adds PR to pipeline's Processes array in last position.
        %       obj.addProcess(PR, POS): Adds PR to pipeline's Processes array in position POS.
            
            arguments
                obj Pipeline
                processToAdd {mustBeNonempty}
                position int64 = length(obj.Processes) + 1;
            end
            
            validator = PipelineValidator();
            validator.verifyIfProcessIsDuplicate(obj, processToAdd);
            validator.verifyPosition(obj, position);
            
            if isa(processToAdd, 'Process')
                processToAdd = {processToAdd};
            end
            
            tempProcesses = {obj.Processes{1:position-1}, processToAdd{:,:}, obj.Processes{position:end}};
            validator.verifyTypeOfProcesses(tempProcesses);
            
            obj.Processes = tempProcesses;
            obj.addEntryToHistory(processToAdd);
            
            
        end
        
        function swapProcess(obj, positionSource, positionDestination)
        % Swaps two processes in pipeline.
        %
        % INPUT
        %       position1 [int64]: must be non-empty.
        %       position2 [int64]: must be non-empty.
        %
        % USAGE
        %       obj.swapProcess(POS_1, POS_2): Swap process in position POS_1 with process in position POS_2.
            
            arguments
                obj Pipeline
                positionSource int64 {mustBeNonempty}
                positionDestination int64 {mustBeNonempty}
            end
            
            validator = PipelineValidator();
            validator.verifyPosition(obj, [positionSource, positionDestination]);
            obj.Processes([positionSource, positionDestination]) = obj.Processes([positionDestination, positionSource]);
            obj.addEntryToHistory(positionSource, positionDestination);
            
        end
        
        function moveProcess(obj, oldPosition, newPosition)
        % Moves process in pipeline.
        %
        % INPUT
        %       oldPosition [int64]: must be non-empty.
        %       newPosition [int64]: must be non-empty.
        %
        % USAGE
        %       obj.moveProcess(POS_1, POS_2): Move process from position POS_1 to position POS_2.
            
            arguments
                obj Pipeline
                oldPosition int64 {mustBeNonempty}
                newPosition int64 {mustBeNonempty}
            end
            
            validator = PipelineValidator();
            validator.verifyPosition(obj, [oldPosition, newPosition]);
            processToMove = obj.Processes{oldPosition};           
            obj.deleteProcess(oldPosition);
            obj.addProcess(processToMove, newPosition); 
            obj.addEntryToHistory();
            
        end
               
        function deleteProcess(obj, position)
        % Deletes process in pipeline.
        %
        % INPUT
        %       position [int64]: must be non-empty.
        %
        % USAGE
        %       obj.deleteProcess(POS): Delete process in position POS.
            
            arguments
                obj Pipeline
                position int64 {mustBeNonempty}
            end
            
            validator = PipelineValidator();
            validator.verifyPosition(obj, position);
            processToDelete = obj.Processes(position);
            obj.Processes = [obj.Processes(1:position-1) obj.Processes(position+1:end)];
            obj.addEntryToHistory(processToDelete);
            
        end
        
        function printProcess(obj)
        % Creates characters describing the pipeline's processes.
        %
        % OUTPUT
        %       processesAsCharacters [char]
        %
        % USAGE
        %       C = obj.printProcess()
        
            disp(PipelinePrinter.convertProcessToCharacters(obj));
           
        end

        function clear(obj)
        % Clears pipeline.
        %
        % USAGE
        %       obj.clear(): Clears pipeline's Processes property.
            
            obj.Processes = obj.getDefaultValueOfAttribute('Processes');
            obj.addEntryToHistory();
            
        end

        function save(obj)
        % Saves pipeline.
        %
        % USAGE
        %       obj.save():
        
%             if ~PipelineValidator.validate()
%                 disp('Invalid');
%                 error('Invalid Pipeline');
%             end
            
            pipelinePath = replace(fullfile(obj.Folder, strcat(obj.Name, obj.Extension)), '\', '/');
            obj.addEntryToHistory(pipelinePath);
            
            exporter = PipelineExporter();
            exporter.export(obj);
        
        end
             
        function print(obj)
        % Creates and displays characters describing the pipeline.
        %
        % OUTPUT
        %       characters [char]
        %
        % USAGE
        %       C = obj.print()
            
            disp(obj.convertToCharacters);
            
        end
        
        function pipelineAsCharacters = convertToCharacters(obj)
            
            pipelineAsCharacters = PipelinePrinter.convertToCharacters(obj);
            
        end
        
        function printDocumentation(obj)
        % Creates and displays characters describing the documentation for every process in pipeline.
        %
        % OUTPUT
        %       characters [char]
        %
        % USAGE
        %       C = obj.printDocumentation()

            disp(PipelinePrinter.convertProcessesDocToCharacters(obj));
            
        end
        
%         function cast(obj, type)
%            
%             for i = 1:length(obj.Processes)
%                 obj.Processes{i} = obj.Processes{i}.castWithType(type);
%             end
%             
%         end
        
        function sFilesOut = run(obj, sFilesIn)
        % Runs pipeline.
        %
        % INPUT
        %       sFilesIn [struct, char]: optionnal, default value = [];
        %
        % OUTPUT
        %       sFilesOut [struct]: sFiles of modified studies.
        %
        % USAGE
        %       sFilesOut = obj.run()
        %       sFilesOut = obj.run(sFilesIn)
        
            arguments
                obj Pipeline;
                sFilesIn = [];
            end
            
            bst_report('Start');
                        
            for i = 1:length(obj.Processes)
                sFilesOut = obj.Processes{i}.run(sFilesIn);
                sFilesIn = sFilesOut;
            end
            
            reportFile = bst_report('Save', []);
            %reportPath = obj.moveReport(reportFile);
            
            obj.addEntryToHistory(reportFile);
            
        end
          
        function isEqual = eq(obj, pipeline)
        % Overloads the operator equality (==).
        % Two Pipelines are equal if they have the same type and the same processes in the same order.
        %
        % INPUT
        %       pipeline [Pipeline]: must be non-empty.
        %
        % OUTPUT
        %       isEqual [logical]: 1 if equal, 0 if not equal.
        %
        % USAGE
        %       pipeline1 == pipeline2: Compare if pipeline1 is equal to pipeline2.
            
            isEqual = true;
            
            if ~strcmpi(obj.Type, pipeline.Type)
                isEqual = false;
            end
            
            if ~all(size(obj.Processes) == size(pipeline.Processes))
                isEqual = false;
            end
            
            if ~all(cellfun(@(x,y) x==y, obj.Processes, pipeline.Processes))
                isEqual = false;
            end

        end
        
        function previousPipeline = getPreviousPipeline(obj)
        % Returns the last version of the pipeline, before the last modification.
        %
        % OUTPUT
        %       previousPipeline [Pipeline]
        %
        % USAGE
        %       previousPipeline = obj.previous()
        
            if isempty(obj.History)
                warning('History is empty, no previous pipeline available.');
                previousPipeline = obj;
            else
                previousPipeline = obj.History(end-1).PipelineCopy;
            end
            
        end
        
        function prFoundIndex = getProcessIndexWithName(obj, processNameToFind)
        % Searches the pipeline and returns the process for which it's name
        % correspond to the input.
        % 
        % INPUT
        %       processName [char]: must be non-empty.
        %
        % OUTPUT
        %       process [Process]
        %
        % USAGE
        %       process = obj.search(processName)
            
            arguments
                obj Pipeline
                processNameToFind string {mustBeNonempty}
            end

            processNameToFind = Process.formatProcessName(processNameToFind);
            nbProcessToFind = length(processNameToFind);
            prFoundIndex = zeros(1, nbProcessToFind) - 1;
            
            for i = 1:nbProcessToFind
                isPrNameIn = (processNameToFind(i) == obj.getProcessesNames());
                if any(isPrNameIn)
                    prFoundIndex(i) = find(isPrNameIn == true);
                end
            end
        
        end
        
        function isIn = isProcessInPipelineWithName(obj, processName)
            
            prIndex = obj.getProcessIndexWithName(processName);
            isIn = prIndex > 0;
            
        end
        
        function isIn = isProcessesInPipeline(obj, processesToVerify)
           
            arguments
                obj Pipeline
                processesToVerify {mustBeNonempty}
            end
            
            m = size(obj.Processes, 1);
            n = size(obj.Processes, 2);
            
            isIn = false(m, n);
            for i = 1:m
                for j = 1:n
                    isIn(i,j) = any(obj.Processes{i,j} == processesToVerify);
                end
            end
            
        end
        
        function isEeg = isEEG(obj)
            
            isEeg = strcmpi(obj.Type, 'eeg');
            
        end
        
        function isMeg = isMEG(obj)
            
            isMeg = strcmpi(obj.Type, 'meg');
            
        end
        
        function isGen = isGeneral(obj)
            
            isGen = strcmpi(obj.Type, 'general');
            
        end
        
        function isSpec = isSpecific(obj)
            
            isSpec = strcmpi(obj.Type, 'specific');
            
        end
        
        function linkToLastReport = getLinkOfLastReport(obj)
           
            linkToLastReport = struct.empty();
            for i = length(obj.History):-1:1
                if strcmpi(obj.History(i).Function, 'Pipeline.run')
                    linkToLastReport = obj.History(i).Parameters;
                    break
                end
            end
            
            if isempty(linkToLastReport)
                warning('No report available. The pipeline has never been applied.');
            end
            
        end
             
        function preparePipelineToBeSavedToJson(obj)
           
            obj.deletePipelinesFromHistory;
            %obj.deleteSProcessFromHistory;
            
        end
        
    end

    methods (Access = private)
                   
        function constructorWithFile(obj, filePath)
        % Creates a pipeline object using the path to a file.
        %
        % INPUT
        %       filePath [char]: must be non-empty. File's extension must be valid.
        %
        % OUTPUT
        %       obj [Pipeline]: Instance of Pipeline class
        %
        % USAGE
        %       obj = obj.constructorWithFile(FP)
            
            arguments
                obj
                filePath char {mustBeNonempty}
            end
            
            structureReadFromFile = FileReader.read(filePath);
            
            obj.convertStructureToPipeline(structureReadFromFile);
            obj.removeLastNHistoryEntry(1);
            
            % Add to history
            obj.addEntryToHistory(filePath);
            
        end

        function convertStructureToPipeline(obj, structureToDecompose)
        % Converts a structure to a pipeline.
        %
        % INPUT
        %       structure [struct]
        %
        % OUTPUT
        %       obj [Pipeline]
        %
        % USAGE
        %       obj = obj.convertStructureToPipeline(S)
        
            arguments
                obj Pipeline
                structureToDecompose struct {mustBeNonempty}
            end
            
            validFieldsInPipeline = intersect(properties(Pipeline), fieldnames(structureToDecompose));
            
            for i = 1:length(validFieldsInPipeline)
                
                field = validFieldsInPipeline{i};
                value = structureToDecompose.(field);
                if iscolumn(value)
                    value = value';
                end
                  
                if strcmp(field, 'Type')
                    continue
                    
                elseif strcmp(field, 'History')
                    historyOfStructureToSet = value;
                    continue 
                    
                elseif  strcmp(field, 'Processes')
                    pr = Process.create(value);
                    if ~iscell(pr)
                        pr = {pr};
                    end
                    obj.Processes = pr;
                    
                else
                    obj.(field) = value;
                end
            end
            
            if isfield(structureToDecompose, 'History')
                obj.History = historyOfStructureToSet;
            end
            %pipelineCreated.addEntryToHistory(structureToDecompose);
            
        end

        function addEntryToHistory(obj, varargin)
        % Adds a new entry to the pipeline's history.
        % By default, an entry contains the caller function, the date/time and a copy of the current pipeline.
        %
        % INPUT
        %       varargin [~]: optionnal, additionnal informations to add to the history.
        %
        % USAGE
        %       obj.addEntryToHistory(): the default entry contains the caller function, the date/time and a copy of the current pipeline.
        %       obj.addEntryToHistory(args): the variable 'args' is added to the default entry.
            
            % Copy of Pipeline
            objCopy = copy(obj);
%             objCopy.Processes.deleteSProcess;
%             objCopy.Processes.deleteFunctionHandle;
            for i = 1:length(objCopy.Processes)
                objCopy.Processes{i}.deleteSProcess;
                objCopy.Processes{i}.deleteFunctionHandle;
            end
            
            % Get caller function
            fctCallStack = dbstack;
            [~, callerFct] = fctCallStack.name;
            
            % Get parameters
            arrayToAddToHistory = [varargin{:}];
            
            row = length(obj.History);
            obj.History(row+1).Function = callerFct;
            obj.History(row+1).Datetime = char(datetime);
            obj.History(row+1).Parameters = arrayToAddToHistory;
            obj.History(row+1).PipelineCopy = objCopy;  
            
        end
      
        function removeLastNHistoryEntry(obj, numberOfEntryToDelete)
        % Removes the last n number of rows from history.
        %
        % INPUT
        %       n [int64]: optionnal, default = 1
        %
        % USAGE
        %       obj.removeLastHistoryLog()
        %       obj.removeLastHistoryLog(n)
            
            arguments
                obj Pipeline
                numberOfEntryToDelete int64 = 1;
            end
            
            if isempty(obj.History)
                return
            end

            obj.History(end-numberOfEntryToDelete+1:end) = [];
            
        end
        
        function reportDestinationPath = moveReport(obj, reportOriginalFilePath)
           
            if (obj.Folder == findprop(obj, 'Folder').DefaultValue)
                folder = pwd;
                warning(['The report will be saved in the following folder:' ...
                        newline folder]);
            else
                folder = obj.Folder;
            end
            
            reportDestinationFolder = fullfile(folder, strcat(obj.Name, '_reports'));
            
            if ~isfolder(reportDestinationFolder)
                mkdir(reportDestinationFolder);
            end
            
            [~, reportFileName, reportFileExtension] = fileparts(reportOriginalFilePath);
            
            reportDestinationPath = fullfile(reportDestinationFolder, strcat(reportFileName, reportFileExtension));          
            movefile(reportOriginalFilePath, reportDestinationPath);
            
        end

        function isValid = isProcessesValid(obj)
           
            % Verify if a process is not already in the pipeline          
            if obj.isProcessesInPipeline(processToAdd)
                eID = 'DuplicateProcess';
                eMsg = 'You are adding a process that is already in this pipeline.';
                throw(obj.createException(eID, eMsg));
            end
            
            isValid = PipelineValidator.validateProcesses;
            
        end
        
        function processesName = getProcessesNames(obj)
           
            if isempty(obj.Processes)
                processesName = string.empty();
                return
            end
            processesName = cellfun(@(x) x.Name, obj.Processes);
            
        end
        
        function deletePipelinesFromHistory(obj)
        % Deletes pipelines objects from history.
        % This method is used when saving to a .json file.
        %
        % USAGE
        %       obj.deletePipelinesFromHistory()
            
            % Delete Pipelines
            for i = 1:length(obj.History)
                obj.History(i).PipelineCopy = [];
            end
            
        end
                
        function deleteSProcessFromHistory(obj)
                       
            for i = 1:length(obj.History)
                parameter = obj.History(i).Parameters;
                if isa(parameter, 'Process')
                    parameter.deleteSProcess;
                end
            end
            
        end
        
    end
    
    methods (Access = protected)
        
        function objCopy = copyElement(obj)
        % Overrides the 'copyElement' to create a deep copy.
        % For more information: https://www.mathworks.com/matlabcentral/answers/268195-ho-to-copy-an-object-deep-copy-which-has-inside-another-object
        %
        % OUTPUT
        %       objCopy [Pipeline]
        %
        % USAGE
        %       objCopy = obj.copyElement()
            
            % Shallow Copy of all elements
            objCopy = copyElement@matlab.mixin.Copyable(obj);
            
            % Deep Copy of Processes (if not empty)
            if ~isempty(obj.Processes)
                %objCopy.Processes = copy(obj.Processes);
                for i = 1:length(objCopy.Processes)
                    objCopy.Processes{i} = copy(obj.Processes{i}); 
                end
            end
            
        end
        
    end

    methods
    % Set and Get Methods
        
        function set.Folder(obj, folder)
           
            arguments
                obj Pipeline
                folder (1,1) string {mustBeNonempty}
            end
            
            % Check if valid folder
            assert(isfolder(folder), ...
            ['The following path to a folder does not exist: ' newline newline char(folder)]);
            
            % Assign folder to property
            obj.Folder = folder;
            
            % Add to history
            obj.addEntryToHistory(folder);
            
        end
        
        function set.Name(obj, name)
            
            arguments
                obj Pipeline
                name (1,1) string {mustBeNonempty}
            end
            
            obj.Name = name;
            
            % Add to history
            obj.addEntryToHistory(name);
            
        end
        
        function set.Extension(obj, extensions)
           
            arguments
                obj Pipeline
                extensions string
            end
            
            extensions = Pipeline.formatExtensionsWithLowerCaseAndDot(extensions);
            extensions = unique(extensions);
            
            % Check if extension is supported
            assert(all(contains(extensions, obj.getSupportedExtension)), ...
                ['The extension of the pipeline is incorrect. ' ...
                'Here are the supported extensions: ' newline newline ...
                char(strjoin(string(obj.getSupportedExtension), '\n'))]);
            
            obj.Extension = extensions;
            
            % Add to history 
            obj.addEntryToHistory(extensions);
            
        end
               
        function set.DateOfCreation(obj, date)
           
            arguments
                obj Pipeline
                date datetime {mustBeNonempty}
            end
            
            obj.DateOfCreation = date;
            
            % Add to history
            obj.addEntryToHistory();
            
        end
            
        function type = get.Type(obj)
           
            if isempty(obj.Processes)
                type = strings(1,1);
                return
            else
                allType = cellfun(@(x) x.getType(), obj.Processes);
                if any(strcmpi(allType, 'eeg'))
                    type = "eeg";
                elseif any(strcmpi(allType, 'meg'))
                    type = "meg";
                elseif any(strcmpi(allType, 'general'))
                    type = "general";
                elseif any(strcmpi(allType, 'specific'))
                    type = "specific";
                end
            end
            
        end

    end
    
    methods (Static, Access = public)
        
        function supportedExtension = getSupportedExtension()
        % Returns supported extension of pipeline.
        %
        % OUTPUT
        %       supportedExtension [string]: cell contains char
        %
        % USAGE
        %       SE = obj.getSupportedExtension()
            
            supportedExtension = Pipeline.SupportedExtension;
            
        end
       
    end
    
    methods (Static, Access = private)
        
        function extensions = formatExtensionsWithLowerCaseAndDot(extensionToFormat)
           
            extensions = lower(extensionToFormat);
            
            for i = 1:length(extensions)
                if ~isequal(extensions{i}(1), '.')
                    extensions(i) = strcat('.', extensions(i));
                end
            end
            
        end
        
        function defaultValue = getDefaultValueOfAttribute(attribute)
           
            props = meta.class.fromName(mfilename('class')).PropertyList;
            for i = 1:length(props)
                if strcmpi(attribute, props(i).Name)
                    defaultValue = props(i).DefaultValue;
                    break
                end
            end
            
        end
       
    end
    
end