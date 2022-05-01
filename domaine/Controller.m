classdef Controller < handle
    
    properties
        
        % Paths
        PipelineSearchPath char;
        ProtocolPath char;
        WorkingFolder char = pwd;
        BstDataBasePath char;
        RawDataSearchPath char;
        ClassPath char = "./classes/";
        ImagesPath char = "./images/";
        BsToolboxPath char = "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/toolboxes/brainstorm3/";
        
        % Variables
        CurrentPipeline Pipeline;
        Type char;
        Analyzer Basic_Analysis;
        Util = Utility.instance();
        
    end
    
    methods
        
        function obj = Controller()
        end
        
        function loadPipeline(obj, file)
           
            obj.CurrentPipeline = Pipeline(file);
            
        end
        
        function switchProcessType(obj, type)
           
            obj.Type = type;
            obj.createAnalyzer;
            
        end
        
        function createAnalyzer(obj)
           
            switch obj.Type
                
                case 'EEG'
                    obj.Analyzer = EEG_Analysis.instance();
                    
                case 'MEG'
                    obj.Analyzer = MEG_Analysis.instance();
                    
            end
            
        end
        
        function str = printCurrentPipeline(obj)
            
            str = obj.CurrentPipeline.print();
            
        end
        
        function clearPipeline(obj)
           
            obj.CurrentPipeline = Pipeline();
            
        end
        
        function runPipeline(obj, sFiles)
            
           obj.CurrentPipeline.run(sFiles);
            
        end
        
        function process = createProcess(obj, name, structure)
            
            if strcmp(obj.Type, 'EEG')
                process = EEG_Process(name);
                
            elseif strcmp(obj.Type, 'MEG')
                process = MEG_Process(name);
                    
            end
            
            process.addParameterStructure(structure);
            
        end
        
        function runProcess(obj, process, sFiles)
           
            process.run(sFiles);
            
        end
        
        function supportedExtensions = getSupportedExtension(obj)
           
            if strcmp(obj.Type, 'EEG')
                supportedExtensions = EEG_Process.getExtensionSupported;
                
            elseif strcmp(obj.Type, 'MEG')
                supportedExtensions = EEG_Process.getExtensionSupported;
                    
            end
            
        end
        
        function sFilesOut = notchFilter(obj, sFiles, frequence)
           
            sFilesOut = obj.Analyzer.notchFilter(sFiles, obj.Type, frequence);
            
        end
        
        function sFilesOut = bandPassFilter(obj, sFiles, frequence)
           
            sFilesOut = obj.Analyzer.bandPassFilter(sFiles, obj.Type, frequence);
            
        end
        
        function sFilesOut = powerSpectrumDensity(obj, sFiles, windowLength)
            
            sFilesOut = obj.Analyzer.powerSpectrumDensity(sFiles, sensorType, windowLength);
            
        end
        
        function sFilesOut = convertEpochsToContinue(obj, sFiles)
            
           assert(isa(obj.Analyzer, 'MEG_Analysis'));
           
           sFilesOut = obj.Analyzer.convertEpochsToContinue(sFiles);
            
        end
        
        function sFilesOut = addEegPosition(obj, sFiles, fileType, cap, electrodeFile)
            
            assert(isa(obj.Analyzer, 'EEG_Analysis'));
            
            sFilesOut = obj.Analyzer.addEegPosition(sFiles, fileType, cap, electrodeFile);
        
        end
        
        function sFilesOut = refineRegistration(obj, sFiles)
       
           sFilesOut = obj.Analyzer.refineRegistration(sFiles);
            
        end
        
        function sFilesOut = projectElectrodesOnScalp(obj, sFiles)
       
           sFilesOut = obj.Analyzer.projectElectrodesOnScalp(sFiles);
            
        end
        
        function sFilesOut = averageReference(obj, sFiles)
       
           sFilesOut = obj.Analyzer.averageReference(sFiles);
            
        end
        
        function sFilesOut = ica(obj, sFiles, nbComponents)
       
           sFilesOut = obj.Analyzer.ica(sFiles, nbComponents, obj.Type);
            
        end
        
        function sFilesOut = detectCardiacArtifact(obj, sFiles, channelName, eventName)
           
            sFilesOut = obj.Analyzer.detectCardiacArtifact(sFiles, channelName, eventName);
            
        end
        
        function sFilesOut = exportToBids(obj, sFiles, BidsPath)
           
            sFilesOut = obj.Analyzer.exportToBids(sFiles, BidsPath);
            
        end
        
        function sFilesOut = reviewRawFiles(obj, subjectName, rawFilePath, fileFormat, channelAlign)
            
            sFilesOut = obj.Analyzer.reviewRawFiles(subjectName, rawFilePath, fileFormat, channelAlign);
            
        end
        
        function createProtocol(obj, protocolName)
            
            obj.Util.createProtocol(protocolName); 
            
        end
        
        function deleteProtocol(obj, protocolName)
            
            obj.Util.deleteProtocol(protocolName);
            
        end
        
        function renameEvent(obj, sFiles, oldName, newName)
           
            obj.Analyzer.renameEvent(sFiles, oldName, newName);
            
        end
        
        function deleteEvent(obj, sFiles, eventName)
           
            obj.Analyzer.deleteEvent(sFiles, eventName);
            
        end
        
        function viewComponents(obj, sFiles)
            
            obj.Analyzer.viewComponents(sFiles);
            
        end
        
        function allProtocols = getAllProtocols(obj)
           
            allProtocols = obj.Util.getAllProtocols();
            
        end
        
        function allEvents = getEvents(obj, sFiles)
            
            allEvents = obj.Util.getEvents(sFiles);
            
        end
        
        function file = exportData(obj, sFile, folder, extension)
            
            file = obj.Util.exportData(sFile, folder, extension);
            
        end
        
        function asgPipelineSearchPath(obj, path)
            
           obj.PipelineSearchPath = path;
            
        end
        
        function path = getPipelineSearchPath(obj)
            
           path = obj.PipelineSearchPath;
            
        end
        
        function asgWorkingFolderPath(obj, path)
            
           obj.WorkingFolder = path;
            
        end
        
        function path = getWorkingFolderPath(obj)
            
           path = obj.WorkingFolder;
            
        end
       
        function asgBstDataBasePath(obj, path)
            
           obj.BstDataBasePath = path;
            
        end
        
        function path = getBstDataBasePath(obj)
            
           path = obj.BstDataBasePath;
            
        end
       
        function asgRawDataSearchPath(obj, path)
            
           obj.RawDataSearchPath = path;
            
        end
        
        function path = getRawDataSearchPath(obj)
            
           path = obj.RawDataSearchPath;
            
        end
        
        function addPaths(obj)
            
            addpath(obj.ClassPath);
            addpath(obj.ImagesPath);
            
        end
        
        function removePaths(obj)
            
            rmpath(obj.ClassPath);
            rmpath(obj.ImagesPath);
            rmpath(obj.BsToolboxPath);
            
        end
        
        function type = getType(obj)
        
            type = obj.Type;
            
        end
        
        function anatomyFileFormat = getAnatomyFileFormat(obj)
            
            switch obj.Type
                case 'EEG'
                    anatomyFileFormat = "FreeSurfer-fast";
                    
                case 'MEG'
                    anatomyFileFormat = "FreeSurfer";
            end
            
        end
        
        function startBrainstorm(obj)
           
            addpath(obj.BsToolboxPath);
            
            % Start Brainstorm without interface
            if ~brainstorm('status')
                brainstorm nogui;
            end
            
            obj.asgBstDataBasePath(bst_get('BrainstormDbDir'));
            
        end
        
        function createWorkingFolder(obj)
           
            if ~isfolder(obj.getWorkingFolderPath)
                mkdir(obj.getWorkingFolderPath);
            end
            
        end
    end
end

