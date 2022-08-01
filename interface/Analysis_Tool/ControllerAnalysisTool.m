classdef ControllerAnalysisTool < Controller
    
    properties (SetAccess = private, GetAccess = ?Analysis_Tool)
        
        % Paths
        WorkingFolder; % [char]
        BstDataBasePath; % [char]
                
        % Folder Name
        AppFolderName = "__APP__";
        
        % Variables
        %BstUtil; % [BstUtility]
        
    end
    
    methods (Access = public)
        
        function obj = ControllerAnalysisTool()
            
            obj.setDefaultWorkingFolder();
            
            % Instantiate BstUtility (brainstorm needs to be launched)
            %obj.BstUtil = BstUtility.instance();
            
            obj.setBstDataBasePath(bst_get('BrainstormDbDir'));
            
        end
        
        function switchType(obj, type)
           
            switchType@Controller(obj, type);
            
        end
        
        function characters = printCurrentPipeline(obj)
            
            if isequal(obj.CurrentPipeline.Name, strings(1,1))
                characters = 'NO PIPELINE CURRENTLY LOADED';
            else
                characters = obj.CurrentPipeline.convertToCharacters();
            end
            
        end
        
        function runPipeline(obj, sFiles)
            
           obj.CurrentPipeline.run(sFiles);
            
        end

        function runProcess(~, process, sFiles)
           
            arguments
                ~
                process Process
                sFiles = []
            end
            
            process.run(sFiles);
            
        end
                               
        function createProtocol(obj, protocolName)
            
            ProtocolManager.createProtocol(protocolName); 
            
        end
        
        function setProtocol(obj, protocolIndex)

            ProtocolManager.setProtocol(protocolIndex);

        end

        function protocolIndex = getProtocolIndex(obj, protocolName)
           
            protocolIndex = ProtocolManager.getProtocolIndex(protocolName);

        end

        function deleteProtocol(obj, protocolName)
            
            ProtocolManager.deleteProtocol(protocolName);
            
        end
        
        function deleteStudy(obj, sFiles)
           
            BstUtility.deleteStudy(sFiles);
            
        end
        
        function renameEvent(~, sFiles, oldName, newName)
           
            Analyzer.instance.renameEvent(sFiles, oldName, newName);
            
        end
        
        function deleteEvent(~, sFiles, eventName)
           
            Analyzer.instance.deleteEvent(sFiles, eventName);
            
        end
        
        function viewComponents(~, sFiles)
            
            Analyzer.instance.viewComponents(sFiles);
            
        end
        
        function allProtocols = getAllProtocols(obj)
            
            allProtocols = ProtocolManager.getAllProtocols();
            
        end
        
        function allEvents = getEvents(obj, sFiles)
            
            allEvents = BstUtility.getEvents(sFiles);
            
        end
        
        function [filePath, sFile] = exportData(obj, sFile, folder, extension)
            
            [filePath, sFile] = BstUtility.exportData(sFile, folder, extension);
            
        end
        
        function setWorkingFolderPath(obj, path)
            
           obj.WorkingFolder = fullfile(path, obj.AppFolderName);
            
        end
        
        function path = getWorkingFolderPath(obj)
            
           path = obj.WorkingFolder;
            
        end
       
        function setBstDataBasePath(obj, path)
            
           obj.BstDataBasePath = path;
            
        end
        
        function path = getBstDataBasePath(obj)
            
           path = obj.BstDataBasePath;
            
        end
        
        function checkIfChannelIsInChannelFile(obj, sFiles, channelToCheck)
            
            BstUtility.checkIfChannelIsInChannelFile(sFiles, channelToCheck);
            
        end
        
        function createWorkingFolder(obj)
           
            if ~isfolder(obj.getWorkingFolderPath)
                mkdir(obj.getWorkingFolderPath);
            end
            
        end

        function setDefaultWorkingFolder(obj)

            username = getenv('USERNAME');
            
            if ispc
                obj.WorkingFolder = fullfile("C:/Users/", username, "/Desktop");
                
            elseif isunix
                obj.WorkingFolder = fullfile("/home/", username);
                
            elseif ismac
                obj.WorkingFolder = fullfile("/Users/", username, "/Desktop");
                
            end

        end
        
    end
           
end