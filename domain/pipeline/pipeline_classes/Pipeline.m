classdef Pipeline
    
    properties (SetAccess = private, GetAccess = public)
        Details;
        Processes;        
    end
    
    methods (Access = public)
        
        function obj = Pipeline(filePath)
            if nargin == 0
                obj.Details = PipelineDetails();
                obj.Processes = ListOfProcesses();
            elseif nargin == 1
                filePath = Pipeline.relativeToAbsolute(filePath);
                if isfile(filePath)
                    obj = PipelineImporter.importFile(filePath);
                    obj = obj.setFile(filePath);
                else
                    error(['Input is not an existing file:' newline filePath]);              
                end               
            end    
        end
        
        function obj = selectFolder(obj)
            folder = uigetdir(pwd, 'Select the folder where to save your pipeline!');
            if folder ~= 0
                obj.Details.setFolder(folder);
            end           
        end
        
        function obj = setFolder(obj, folder)
            obj.Details = obj.Details.setFolder(folder);
            obj = obj.addEntryToHistory(folder);
        end
        
        function folder = getFolder(obj)
            folder = obj.Details.Folder;
        end
        
        function obj = setExtension(obj, extension)
            obj.Details = obj.Details.setExtension(extension);
            obj = obj.addEntryToHistory(extension);            
        end
        
        function extension = getExtension(obj)
            extension = obj.Details.Extension;
        end
        
        function obj = setName(obj, name)
            obj.Details = obj.Details.setName(name);
            obj = obj.addEntryToHistory(name);
        end
        
        function name = getName(obj)
            name = obj.Details.getName();
        end
                           
        function obj = setFile(obj, file)
            obj.Details = obj.Details.setFile(file);
        end
        
        function obj = setDate(obj, dateOfCreation)
            obj.Details = obj.Details.setDate(dateOfCreation);
            obj = obj.addEntryToHistory(dateOfCreation); 
        end
        
        function date = getDate(obj)
            date = obj.Details.DateOfCreation; 
        end
        
        function path = getPath(obj, extension)
            arguments
                obj
                extension = obj.getExtension();
            end
            path = fullfile(obj.getFolder(), strcat(obj.getName(), extension)); 
        end
        
        function obj = setDocumentation(obj, documentation)
            obj.Details = obj.Details.setDocumentation(documentation);
            obj = obj.addEntryToHistory(documentation);           
        end
        
        function documentation = getDocumentation(obj)
            documentation = obj.Details.Documentation;
        end
        
        function processClass = getProcessClass(obj)
            processClass = obj.Processes.getClass();
        end
        
        function process = getProcess(obj, index1, index2)
            arguments
                obj
                index1 int16 = double.empty()
                index2 int16 = double.empty()
            end
            process = obj.Processes.getProcess(index1, index2);
        end
        
        function numberOfProcess = getNumberOfProcess(obj)
            numberOfProcess = obj.Processes.getNumberOfProcess();
        end
        
        function obj = addProcess(obj, processToAdd, position)
            arguments
                obj Pipeline
                processToAdd cell {mustBeNonempty}
                position int64 = obj.Processes.getNumberOfProcess() + 1;
            end
            obj.Processes = obj.Processes.addProcess(processToAdd, position);
            obj = obj.addEntryToHistory(processToAdd, position);
        end
        
        function obj = swapProcess(obj, positionSource, positionDestination)
            obj.Processes = obj.Processes.swapProcess(positionSource, positionDestination);
            obj = obj.addEntryToHistory(positionSource, positionDestination);
        end
        
        function obj = moveProcess(obj, oldPosition, newPosition)
            obj.Processes = obj.Processes.moveProcess(oldPosition, newPosition);
            obj = obj.addEntryToHistory(oldPosition, newPosition);
        end
               
        function obj = deleteProcess(obj, position)
            obj.Processes = obj.Processes.remove(position);
            obj = obj.addEntryToHistory(position);
        end

        function obj = clear(obj)
            obj.Processes = obj.Processes.clear();
            obj = obj.addEntryToHistory();            
        end

        function obj = save(obj)
            obj = obj.addEntryToHistory(obj.getPath());
            PipelineExporter.export(obj);
        end
        
        function obj = save2mat(obj)
            originalExtension = obj.getExtension();
            if strcmpi(originalExtension, '.mat')
                obj = obj.save();
            else
                obj = obj.setExtension('.mat');
                obj = obj.save();
                obj = obj.setExtension(originalExtension);
            end            
        end
        
        function obj = save2json(obj)
            originalExtension = obj.getExtension();
            if strcmpi(originalExtension, '.json')
                obj = obj.save();
            else
                obj = obj.setExtension('.json');
                obj = obj.save();
                obj = obj.setExtension(originalExtension);
            end  
        end
        
        function disp(obj)
           disp(obj.convertToCharacters());
        end
        
        function pipelineAsCharacters = convertToCharacters(obj)
            pipelineAsCharacters = char(strjoin(obj.convertToString(), '\n\n'));            
        end
        
        function printDocumentation(obj)
            disp(PipelinePrinter.convertProcessesDocToCharacters(obj));            
        end
        
        function [obj, sFilesOut] = run(obj, sFilesIn)
            arguments
                obj Pipeline;
                sFilesIn = [];
            end            
            bst_report('Start');                        
            for i = 1:obj.Processes.getNumberOfProcess()
                pr = obj.getProcess(i);
                disp(['PROCESS> ' Process.unformatProcessName(pr.getName())]);
                sFilesOut = pr.run(sFilesIn);
                sFilesIn = sFilesOut;
            end            
            reportFile = bst_report('Save', []);
            %reportPath = obj.moveReport(reportFile);            
            obj.addEntryToHistory(reportFile);            
        end
          
        function isEqual = eq(obj, pipeline)
            isEqual = obj.Processes == pipeline.Processes;
        end
        
        function previousPipeline = getPreviousPipeline(obj)
            previousPipeline = obj.Details.History.getPreviousPipeline();
        end
        
        function index = getProcessIndexWithName(obj, processNameToFind)
            index = obj.Processes.getProcessIndexWithName(processNameToFind);        
        end
        
        function index = getProcessIndex(obj, process)
            index = obj.Processes.getProcessIndex(process);        
        end
        
        function process = findProcessWithName(obj, name)
            process = obj.getProcess(obj.getProcessIndexWithName(name));
        end
        
        function isIn = isProcessInPipelineWithName(obj, processName)
            isIn = obj.Processes.isProcessInWithName(processName);            
        end
        
        function isIn = isProcessIn(obj, process)
            isIn = obj.Processes.isProcessIn(process); 
        end
        
        function isDefault = isDefault(obj)
            isDefault = obj.Details.isEmpty() & obj.Processes.isEmpty();            
        end
        
        function json = jsonencode(obj, varargin)
            s = struct();
            s.Folder = obj.getFolder();
            s.Name = obj.getName();
            s.Extension = obj.getExtension();
            s.Date = obj.getDate();
            %s.Documentation = obj.getDocumentation();
            %s.Hash = obj.Details.getHash();
            s.Processes = obj.Processes.getProcess();
            json = jsonencode(s, varargin{:});
        end
        
    end

    methods (Access = private)

        function obj = addEntryToHistory(obj, varargin)
            obj.Details = obj.Details.addEntryToHistory(obj, varargin);
        end
        
        function pipAsString = convertToString(obj)
            pipAsString = strings(1, 7);
            pipAsString(1) = ['PIPELINE', newline, char(obj.getName())];
            pipAsString(2) = ['FOLDER', newline, char(obj.getFolder())];
            pipAsString(3) = ['EXTENSION', newline, char(obj.getExtension())];
            pipAsString(4) = ['DATE OF CREATION', newline, char(obj.getDate())];
            pipAsString(5) = ['TYPE', newline, char(obj.getProcessClass())];
            pipAsString(6) = ['NUMBER OF PROCESS', newline, num2str(obj.getNumberOfProcess())];
            pipAsString(7) = ['LIST OF PROCESS', newline, obj.Processes.convertToCharacters()];       
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

    end
    
    methods (Static, Access = public)
        
        function filepath = relativeToAbsolute(filepath)
            configuration = Configuration();
            configuration = configuration.loadConfiguration();
            if startsWith(filepath, '.')
                filepath = fullfile(configuration.getPipelinePath(), filepath);
            end 
        end
        
        function supportedExtension = getSupportedExtension()
            supportedExtension = Pipeline.SupportedExtension;            
        end
       
    end

end