classdef Pipeline < handle & matlab.mixin.Copyable
    %
    % Class: Pipeline
    %
    % Pipeline Properties:
    %   Name - Name               
    %   Extension - Extension (.mat/.json)
    %   Folder - Folder
    %   Date - Date of creation
    %   Type - Type (EEG/MEG)
    %   Processes - Processes
    %   History - History
    %   Documentation - Documentation
    %   NumberOfProcess [Dependant] - Number of Proceses
    %
    % Pipeline Methods:
    
    properties (Access = public)
        
        Name char; % Characters
        Extension char; % Characters (.mat/.json)
        Folder char; % Character
        Date char; % Character
        Type char; % Character (EEG/MEG)
        Processes Process; % Processes
        History cell; % Cell
        Documentation char; % Character
        
    end
    
    properties (Access = protected)

      Util = Utility();
      SupportedFileFormat = {'.mat', '.json'};
      SupportedType = {'EEG', 'MEG'};
      
    end
    
    properties (Dependent)
        NumberOfProcess double % [Dependant] double
    end
    
    methods
        
        function obj = Pipeline(input)
            
            arguments
                input char = char.empty();
            end
            
            % If no input
            if isempty(input)
                obj.Date = Utility.get_Time_Now();
                obj.addToHistory();
                
            % If input is a file
            elseif isfile(input)
                obj = obj.loadFile(input);
                obj.verifyType();
                
            % Else, assign input as name 
            else
                obj.asgFile(input);
            end
            
        end
                           
        function asgFile(obj, file)
           
            arguments
                obj Pipeline
                file char {mustBeNonempty} 
            end
            
            % Assign folder name and extension
            [folder, name, extension] = fileparts(file);
            
            obj.Name = name;
            
            if ~isempty(extension)
                obj.Extension = extension;
            end
            
            if ~isempty(folder)
                obj.Folder = folder;
            end
            
            
        end
        
        function asgFolder(obj, folder)
            
            arguments
                obj Pipeline
                folder char = char.empty();
            end
            
            % If folder is empty (default value)
            if isempty(folder)
                
                folder = uigetdir(pwd, 'Select the folder where to save your pipeline!');
                if folder == 0
                    return
                end
                
            end            
            
            % Assign folder to property
            obj.Folder = folder;
            
            % Add to history
            obj.addToHistory(folder);
            
        end
        
        function asgExtension(obj, extension)
            
            arguments
                obj Pipeline
                extension char {mustBeNonempty}
            end
            
            obj.Extension = extension;
            
            % Add to history 
            obj.addToHistory(extension);
        end
        
        function asgName(obj, name)
            
            arguments
                obj Pipeline
                name char {mustBeNonempty}
            end
            
            obj.Name = name;
            
            % Add to history
            obj.addToHistory(name);
            
        end
        
        function addProcess(obj, process, pos)
            
            arguments
                obj Pipeline
                process Process {mustBeNonempty}
                pos double = length(obj.Processes) + 1;
            end
            % Pre-condition
            % Verify type of process matches type of pipeline
            assert(isa(process, class(obj.Processes)), ['The Process you''re adding ' ...
                        'should be of type ' class(obj.Processes) ...
                        ' because the pipeline is of type ' obj.Type '.']);

            % Verify if process is not already in pipeline
            
            for i = 1:length(obj.Processes)
                
                assert(process ~= obj.Processes(i), ...
                    ['The pipeline already has this process: ' newline process.print()]);
                
            end
            
            % Verify validity of position
            % If not default value
            if pos ~= length(obj.Processes) + 1
                obj.verifyPosition(pos);
            end
            
            % Add process
            if isempty(obj.Processes)
                obj.Processes = process;
                obj.verifyType;
            else
                obj.Processes = [obj.Processes(1:pos-1) process obj.Processes(pos:end)];
            end
            
            % Add to history
            obj.addToHistory(process);
            
        end
        
        function swapProcess(obj, pos1, pos2)
            
            arguments
                obj Pipeline
                pos1 double {mustBeNonempty}
                pos2 double {mustBeNonempty}
            end
            
            % Verify validity of position
            obj.verifyPosition([pos1, pos2]);
            
            % Swap processes
            obj.Processes([pos1, pos2]) = obj.Processes([pos2, pos1]);
            
            % Add to history
            obj.addToHistory();
            
        end
        
        function moveProcess(obj, old_pos, new_pos)
            
            arguments
                obj Pipeline
                old_pos double {mustBeNonempty}
                new_pos double {mustBeNonempty}
            end
            
            % Verify validity of position
            obj.verifyPosition([old_pos, new_pos]);
            
            % Move process
            prToDelete = obj.Processes(old_pos);           
            obj.deleteProcess(old_pos);
            obj.addProcess(prToDelete, new_pos); 
            
            % Add to istory
            obj.addToHistory();
            
        end
               
        function deleteProcess(obj, pos)
            
            arguments
                obj Pipeline
                pos double {mustBeNonempty}
            end
            
            % Verify validity of position
            obj.verifyPosition(pos);
            
            % Save process to delete
            processDeleted = obj.Processes(pos);
            
            % Delete process
            obj.Processes = [obj.Processes(1:pos-1) obj.Processes(pos+1:end)];
            
            % Add to history
            obj.addToHistory(processDeleted);
            
        end
        
        function ch = printProcess(obj)
           
            % If pipeline is empty
            if isempty(obj.Processes)
                ch = 'The pipeline is empty';
                
            else
                ch = strings(1, length(obj.Processes));

                for i = 1:length(ch)
                    ch(i) = [num2str(i), '. ', obj.Processes(i).print()];
                end
               
                ch = char(strjoin(ch, '\n'));
            end           
        end

        function clear(obj)
            
            obj.Processes = Process.empty();
            obj.addToHistory();
            
        end
        
        function save(obj)
            % Pre-condition
            % Verify if the folder is valid
            assert(isfolder(obj.Folder), ...
                ['The pipeline does not have a folder! Run the following line: ' ...
                newline newline inputname(1) '.asgFolder();']);
            
            % Verify if the pipeline has a name
            assert(~isempty(obj.Name), ...
                ['The pipeline does not have a name! Run the following line ' ...
                '(and replace MyPipelineName by your name!): ' ...
                newline newline inputname(1) '.asgName(myPipelineName)']);

            % Verify if extension is supported
            assert(any(strcmp(obj.SupportedFileFormat, obj.Extension)), ...
                ['The extension of the pipeline is incorrect (' obj.Extension ').' ...
                'Here are the supported extensions: ' newline newline ...
                char(strjoin(string(obj.SupportedFileFormat), '\n'))]);
            
            % Add to history
            obj.addToHistory(fullfile(obj.Folder, strcat(obj.Name, obj.Extension)));
            
            % Save pipeline
            switch obj.Extension
                case '.mat'
                    obj.save2mat();
                    
                case '.json'
                    obj.save2json();
            end
            
        end
             
        function ch = print(obj)
            
            str_pipeline = strings(1, 6);
            
            str_pipeline(1) = ['PIPELINE', newline, obj.Name '[' obj.Extension ']'];
            str_pipeline(2) = ['FOLDER', newline, obj.Folder];
            str_pipeline(3) = ['DATE OF CREATION', newline, obj.Util.formatDateToString(obj.Date)];
            str_pipeline(4) = ['TYPE', newline, obj.Type];
            str_pipeline(5) = ['NUMBER OF PROCESS', newline, num2str(length(obj.Processes))];
            
            processes = strings(1, length(obj.Processes));
            for i = 1:length(processes)
                processes(i) = [num2str(i) '. ' obj.Processes(i).print()];
            end
            
            str_pipeline(6) = ['LIST OF PROCESS', newline, char(strjoin(processes, newline))];
            
            ch = char(strjoin(str_pipeline, '\n\n'));
            disp(ch);
        end
        
        function addDocumentation(obj, documentation)
            % Modify the documentation.
            % PRECONDITION: The documentation must be of type characters.
            % param[in]: documentation [char]
            
            arguments
                obj Pipeline
                documentation char
            end
            
            % Assign documentation to property
            obj.Documentation = documentation;
        end
        
        function printDocumentation(obj)
            
            % Initialize variable
            documentation = strings(1, length(obj.Processes));
           
            % Loop through Processes and get documentation
            for i = 1:length(obj.Processes)
                
                documentation(i) = obj.Processes(i).printDocumentation();
                
            end
            
            % Build pipeline documentation
            documentation = ['PIPELINE' sprintf('\n\t\t') ...
                            obj.Documentation newline newline ...
                            char(strjoin(documentation, '\n\n'))];
            
            disp(documentation);
        end
        
        function run(obj, sFilesIn)
            
            arguments
                obj Pipeline;
                sFilesIn struct = [];
            end
            
            % Loop through Processes
            for i = 1:length(obj.Processes)
               
                % Run Process
                sFiles = obj.Processes(i).run(sFilesIn);
                
                % Add to history
                obj.addToHistory(obj.Processes(i), sFilesIn, sFiles);
                
                % Assign output of process to the next process' input
                sFilesIn = sFiles;
                
            end            
        end
          
        function isEqual = eq(obj, pipeline)
            % Two Pipelines are equal if they have the same type and
            % the same processes in the same order
            % (two proceses are equal if they have the same parameters).
            
            isEqual = true;
            
            % Compare Type
            if ~strcmp(obj.Type, pipeline.Type)
                isEqual = false;
                return
                
            % Compare Processes
            elseif ~isequal(obj.Processes, pipeline.Processes)
                isEqual = false;
                return
                
            end
        end
       
        % GET AND SET METHODS
        function set.Folder(obj, folder)
           
            arguments
                obj Pipeline
                folder char {mustBeNonempty}
            end
            
            % Check if valid folder
            assert(isfolder(folder), ...
            ['The following path to a folder does not exist: ' newline newline folder]);
            
            % Assign folder to property
            obj.Folder = folder;
            
        end
        
        function set.Name(obj, name)
            
            arguments
                obj Pipeline
                name char {mustBeNonempty}
            end
            
            obj.Name = name;
            
        end
        
        function set.Extension(obj, extension)
           
            arguments
                obj Pipeline
                extension char {mustBeNonempty}
            end
            
            % Check if extension is supported
            assert(any(strcmp(obj.SupportedFileFormat, extension)), ...
                ['The extension of the pipeline is incorrect (' extension ').' ...
                'Here are the supported extensions: ' newline newline ...
                char(strjoin(string(obj.SupportedFileFormat), '\n'))]);
            
            % Assign extension
            obj.Extension = extension;
            
        end
        
        function set.Type(obj, type)
           
            arguments
                obj Pipeline
                type char {mustBeNonempty}
            end
            
            type = upper(type);
            
            assert(any(strcmp(type, obj.SupportedType)));
            
            if ~isempty(obj.Processes)
                switch upper(type)
                    case 'EEG'
                        assert(isa(obj.Processes, 'EEG_Process'));

                    case 'MEG'
                        assert(isa(obj.Processes, 'MEG_Process'));
                end
            end
            
            % Assign type to pipeline
            obj.Type = upper(type);
            
        end
        
        function set.NumberOfProcess(~, n)
            
           assert(n >= 0);
            
        end
        
        function numberOfProcess = get.NumberOfProcess(obj)
            
            numberOfProcess = length(obj.Processes);
            
        end
        
    end

    methods (Access = protected)
                
        function obj = loadFile(obj, filePath)

            [~, ~, extension] = fileparts(filePath);
            
            switch extension
                
                case '.mat'
                    file = load(filePath);
                    obj = obj.decomposeStructure(file);
                    
                case '.json'
                    fileID = fopen(filePath); 
                    raw = fread(fileID, inf); 
                    str = char(raw'); 
                    fclose(fileID); 
                    structure = jsondecode(str);
                    obj = obj.decomposeStructure(structure);

                otherwise
                    error(['The file format ' extension ' is not supported!']);
                    
            end
            
            obj.addToHistory(filePath);
            
        end
        
        function structure = createStructure(obj)
            
            % Initialize structure
            structure = struct();
            
            % Get Pipeline's properties
            prop = properties(obj);
            
            % Loop through properties to create structure.
            for i = 1:length(prop)
                
                    structure.(prop{i}) = obj.(prop{i});
            end
            
        end
        
        function obj = decomposeStructure(obj, structure)
        
            % Get fields that are in the strucutre and in the Pipeline's
            % properties
            correctFields = intersect(properties(obj), fieldnames(structure));
            
            % Loop through fields
            for i = 1:length(correctFields)
                
                field = correctFields{i};
                
                % When importing Json, the processes are structure (and not
                % of class Process)
                if strcmp(field, 'Processes') && isa(structure.(field), 'struct')
                    
                    processes = structure.(field); % structure.Processes
                    
                    % Loop through processes
                    for j = 1:length(processes)
                        % Create process with structure input
                        obj.addProcess(EEG_Process(processes(j)));
                        
                        % Remove the log that the method addProcess() will
                        % add
                        obj.removeLastHistoryLog();
                    end
                    
                else
                    obj.(field) = structure.(field);
                    
                end
            end
            
        end
        
        function addToHistory(obj, varargin)
            
            % Get caller function
            fctCallStack = dbstack;
            [~, callerFct] = fctCallStack.name;
            
            % Add function name and date/time to history
            row = size(obj.History, 1);
            obj.History{row+1, 1} = callerFct;
            obj.History{row+1, 2} = Utility.get_Time_Now();
            
            % Deep copy of Pipeline
            objCopy = copy(obj);
            
            % Keep only function name and date/time in history
            if size(obj.History, 2) > 2
                objCopy.History(:,3:end) = [];
            end
            
            % Delete all sProcess
            objCopy.deleteSProcess();
            
            % Add Copy of Current Pipeline to history
            obj.History{row+1, 3} = objCopy;
            
            % varargin represents the data to add in history for that log
            for i = 1:length(varargin)
                
                % If Process, deep copy, remove sProcess and add Name of
                % process to log
                if any(strcmp(superclasses(varargin{i}),'Process'))
                    varargin{i} = copy(varargin{i});
                    varargin{i}.deleteSProcess();
                    cellToAdd = [varargin(1:i-1) varargin{i}.Name varargin(i:end)];
                else
                    cellToAdd = varargin(i);
                end
                obj.History(row+1, 4:4+length(cellToAdd)-1) = cellToAdd;
            end
            
        end
        
        function verifyPosition(obj, pos)
            
            arguments
               obj Pipeline
               pos double {mustBeNonempty}
            end
            
            assert(all(pos > 0), 'The indexes must be greater than 0!');
                
            assert(all(pos <= length(obj.Processes)), ...
                    ['The indexes must be smaller than the number of processes ' ...
                    '(Current number of processes: ', num2str(length(obj.Processes)), ').']);
            
        end
       
        function verifyType(obj)
            
            switch class(obj.Processes)
                case 'EEG_Process'
                    obj.Type = 'EEG';
                    
                case 'MEG_Process'
                    obj.Type = 'MEG';
                    
                case 'Process'
                    obj.Type = char.empty();
            end
        end
        
        function deleteSProcess(obj)
           % This function is only applied to a pipeline before it is saved to .json.
           % Remove every sProcess of every Process of the pipeline.
           % The function-handle cannot be saved to a .json.
           
           % Loop through all Processes
            for i = 1:length(obj.Processes)

                obj.Processes(i).deleteSProcess();

            end

        end
        
        function objCopy = copyElement(obj)
            % Shallow Copy of all elements
            objCopy = copyElement@matlab.mixin.Copyable(obj);
            
            % Deep Copy of Processes
            objCopy.Processes = copy(obj.Processes);
        end
        
        function removeLastHistoryLog(obj, n)
            % Remove the last n number of rows from history.
            
            arguments
                obj Pipeline
                n double = 1;
            end
            
            if isempty(obj.History)
                return
            end

            % Remove form history
            obj.History(end-n+1:end, :) = [];
            
        end
        
        function save2mat(obj)
            
            % Create and save mat file
            structure = obj.createStructure();
            save(fullfile(obj.Folder, obj.Name), "-struct", "structure");
            
        end
        
        function save2json(obj)
        
            % Deep Copy
            objCopy = copy(obj);

            % Delete sProcess of every Process (function handle
            % cannot be converted to json)
            objCopy.deleteSProcess();

            % Remove Processes and older Pipelines form history
            % (not useful for json file)
            if size(objCopy.History, 2) > 4
                objCopy.History(:, 5:end) = []; % Remove Processes
            end
            objCopy.History(:, 3) = []; % Remove Pipelines

            % Transpose history cell for a better fit to json file
            objCopy.History = objCopy.History';

            % Create write and close json file
            fileID = fopen(fullfile(obj.Folder, strcat(obj.Name, obj.Extension)), 'wt');
            fprintf(fileID, jsonencode(objCopy, 'PrettyPrint', true));
            fclose(fileID);
        
        end
        
    end
end