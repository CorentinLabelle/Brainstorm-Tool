classdef Process < handle & matlab.mixin.Copyable
    
    properties (SetAccess = ?ProcessFactory, GetAccess = public)
        
        % Process' name
        % [string]: Only keywords
        Name (1,1) string;
        
        % Process' date of creation
        % [datetime]
        Date (1,1) datetime = datetime;
        
        % Process' parameters
        % [string]
        Parameters (1,1) struct;
        
        % Process' documentation
        % [char]
        Documentation char;
        
        % Process' history
        % [struct]
        History struct;
        
        % Is the process general or specific
        % [logical]: True if process can be applied only to EEG or MEG, False otherwise
        IsGeneral (1,1) logical;
        
    end
    
    properties (SetAccess = ?ProcessFactory, GetAccess = private)

        % Process' fName
        % [char]: Brainstrom's function name
        fName char;
        
        % Analyzer's function handle
        % [function_handle]
        AnalyzerFct; 
                
        % Process' sProcess
        % [struct]: Brainstorm's structure for the function
        sProcess struct;
        
    end
    
    methods (Access = public)
    
        function obj = Process(~)
            
            if nargin ~= 0
                error([ 'To create a process, use the following synthax:' newline ...
                        'Process.create()']);
            end
            
        end
        
%         function castedProcess = cast(obj, finalCls)
%            
%             converter = ProcessConverter();
%             castedProcess = converter.cast(obj, finalCls);
%             
%         end

%         function castedProcess = castWithType(obj, type)
%             
%             processGetter = ProcessDefaultInfoGetter();
%             finalCls = processGetter.getClsWithPrType(type);
%             
%             castedProcess = obj.cast(finalCls);
%             
%         end
        
        function setParameter(obj, fieldToSet, valueToSet)
            % obj.setParameter(field, parameter)
            % Adds the field 'field' and the corresponding value 'parameter' to the parameter structure of the process 'obj'.
            %
            % PRECONDITION:  The field must be of type characters.
            %                The field must be a keyword.
            %
            % param[in]: field [char]
            %            parameter [~]

            arguments 
                obj Process
            end

            arguments (Repeating)
                fieldToSet char
                valueToSet
            end
            
            structureToAdd = struct();
            for i = 1:length(fieldToSet)
                fieldToSet{i} = Process.formatParameterName(fieldToSet{i});
                structureToAdd.(fieldToSet{i}) = valueToSet{i};
            end

            obj.setParameterWithStructure(structureToAdd);
            
        end
       
        function setParameterWithStructure(obj, paramStruct)
            
            arguments
                obj Process
                paramStruct struct {mustBeNonempty}
            end
            
            parameterSetter = ProcessParameterSetter();
            obj.Parameters = parameterSetter.setParameter(obj.Parameters, paramStruct);
            
        end
        
        function setDocumentation(obj, documentation)
            % obj.addDocumentation(documentation)
            % Add documentation to the process 'obj'.
            %
            % PRECONDITION: The documentation must be of type characters.
            %
            % param[in]: documentation [char]
                        
            arguments
                obj Process;
                documentation string;
            end
            
            m = size(obj, 1);
            n = size(obj, 2);
            for i = 1:m
                for j = 1:n
                    obj(i,j).Documentation = char(documentation(i,j));
                end       
            end
            
        end
        
        function openWebDocumentation(obj)
            % Open web documentation from Brainstorm website.
            
            for i = 1:numel(obj)
                if ~isempty(obj(i).sProcess)
                    web(obj(i).sProcess.Description);
                end
            end
        
        end

        function sFilesOut = run(obj, sFilesIn)

            arguments
                obj Process
                sFilesIn = [];
            end
            
            if ~isa(sFilesIn, 'struct') && ~isempty(sFilesIn)
                sFilesIn = SFileManager.getsFileFromMatLink(sFilesIn);
            end
            
            if strcmpi(obj.getType, 'specific')
                dataType = SFileManager.getDataTypeFromsFile(sFilesIn);
                analyzer = Process.getAnalyzerWithType(dataType);
            else
                analyzer = obj.getAnalyzer();
            end
            
            sFilesOut = obj.AnalyzerFct(analyzer, obj.Parameters, sFilesIn);
            %obj.addToHistory();
           
        end
        
        function isEqual = eq(obj, processes)

            arguments
                obj Process
                processes Process;
            end
            
            if isempty(processes)
                isEqual = false;
            else
                isEqual =   strcmp([obj.getType], [processes.getType]) & ...
                            strcmp([obj.Name], [processes.Name]);
            end
            
        end
        
        function isNotEqual = ne(obj, processes)
            
            arguments
                obj Process
                processes Process;
            end
            
            isNotEqual = ~(obj == processes);
            
        end
        
%         function isIn = isIn(obj, processesToVerify)
%             
%             
%         
%         end
               
%         function prFoundIndex = findIndex(obj, prNames)
%             
%             arguments
%                 obj
%                 prNames string
%             end
%             
% 
%             
%         end
        
        function deleteFunctionHandle(obj)
            
            for i = 1:numel(obj)
                obj(i).AnalyzerFct = [];
                if ~isempty(obj(i).sProcess)
                    obj(i).sProcess.Function = [];
                end
            end
            
        end
        
        function setSProcess(obj)
            
            for i = 1:numel(obj)
                obj(i).sProcess = panel_process_select('GetProcess', obj(i).fName);
            end
            
        end
        
        function deleteSProcess(obj)
            
            for i = 1:numel(obj)
                obj(i).sProcess = [];
            end
            
        end

        function print(obj)
            % Displays the process.
            
            % param[out]: Process formated [char]
            
            disp(obj.convertToCharacters);
              
        end
        
        function processAsCharacters = convertToCharacters(obj)
            
            processAsString = ProcessPrinter.convertToString(obj);
            processAsCharacters = [newline char(strjoin(processAsString, '\n\n'))];
            
        end
              
        function docAsCharacters = convertDocumentationToCharacters(obj)
           
           docAsCharacters = char(strjoin(...
               ProcessPrinter.convertDocumentationToString(obj), '\n')); 
            
        end
        
        function printDocumentation(obj)
           % Displays the documentation.
           % param[out]: Documentation formated [char]
           
           disp(obj.convertDocumentationToCharacters);
           
        end
        
        function extension = getSupportedDatasetExtension(obj)
           
            extension = GetDatasetExtension(obj.getType);
            
        end
        
    end
     
    % Casting functions
    methods (Access = public)
        
%         function specPr = SpecificProcess(obj)
%             
%             finalCls = feval([mfilename('class') '.getCurrentFunctionName']);
%             converter = ProcessConverter();
%             specPr = converter.cast(obj, finalCls);
%             
%         end
        
%         function generalPr = GeneralProcess(obj)
%             
%             finalCls = feval([mfilename('class') '.getCurrentFunctionName']);
%             converter = ProcessConverter();
%             generalPr = converter.cast(obj, finalCls);
%             
%         end
        
%         function eegPr = EEG_Process(obj)
%             
%             finalCls = feval([mfilename('class') '.getCurrentFunctionName']);
%             converter = ProcessConverter();
%             eegPr = converter.cast(obj, finalCls);
%             
%         end
        
%         function megPr = MEG_Process(obj)
%             
%             finalCls = feval([mfilename('class') '.getCurrentFunctionName']);
%             converter = ProcessConverter();
%             megPr = converter.cast(obj, finalCls);
%             
%         end
        
    end
     
    methods (Static, Access = public)
        
        function process = create(input)
           
            factory = ProcessFactory();
            process = factory.create(input);
            
        end
                 
        function printAvailableProcesses()
            
            ProcessPrinter.printAvailableProcesses;
            
        end
        
        function allProcesses = getAllProcesses()
            
            processGetter = ProcessDefaultInfoGetter();
            allProcesses = processGetter.getAllProcesses;
            
        end
        
        function processCls = getProcessClasses()
           
            processCls = string(fieldnames(Process.getAllProcesses)');
            
        end
        
        function cls = getProcessClsWithType(type)
           
            processGetter = ProcessDefaultInfoGetter();
            cls = processGetter.getClsWithPrType(type);
            
        end
        
        function cls = getClsWithName(prName)
           
            processGetter = ProcessDefaultInfoGetter();
            cls = processGetter.getClsWithPrName(prName);
            
        end
        
%         function initializedPrStruct = getInitializedPrStruct(cls, prName)
%            
%             processGetter = ProcessDefaultInfoGetter();
%             initializedPrStruct = processGetter.getInitializedPrStruct(cls, prName);
%             
%         end
        
        function prName = formatProcessName(prName)
           
            prName = strtrim(prName);
            prName = lower(prName);
            prName = strrep(prName, ' ', '_');
            prName = strrep(prName, '-', '_');
            
        end
        
        function parameterName = formatParameterName(parameterName)
           
            parameterName = Process.formatProcessName(parameterName);
            
        end

    end
    
    methods (Static, Access = protected)
        
        function callerFctName = getCurrentFunctionName()
            
            stack = dbstack;
            [~, callerFct] = stack.name;
            callerFctName = callerFct(find(callerFct == '.')+1:end);
            
        end
        
%         function addToHistory(obj)
%             % Adds an entry to the history of the process everytime the
%             % process is ran. The entry has the name of the process and the
%             % date/time.
% 
%             % Get row index
%             %row = size(obj.History, 1);
%             
% %             obj.History{row+1, 1} = obj.Name;
% %             obj.History{row+1, 2} = datetime;
%             
%         end

        function analyzer = getAnalyzerWithType(type)
            
            processGetter = ProcessDefaultInfoGetter();
            cls = processGetter.getPrClsWithType(type);
            analyzer = eval([cls '.getAnalyzer']);
            
        end
            
    end
        
    methods
        
        function doc = get.Documentation(obj)
            
            doc = obj.Documentation;
            if isempty(obj.Documentation)
                doc = 'No Documentation';
            end
                  
        end
       
    end
   
end