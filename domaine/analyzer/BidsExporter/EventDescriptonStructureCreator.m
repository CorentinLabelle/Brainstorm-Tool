classdef EventDescriptonStructureCreator < handle
    
    properties (Access = private)
        
        sFiles;
        EventDescriptionFilePath char;
        
    end
    
    methods (Access = public)
               
        function obj = EventDescriptonStructureCreator(sFiles)
            
            obj.sFiles = sFiles;
            
        end
        
        function filePath = getEventDescriptionFilePath(obj)
            
            obj.getEventDescription();
            filePath = obj.EventDescriptionFilePath;
            
        end
        
    end  
    
    methods (Access = private)

        function createEventDescriptionsFile(obj)
            
            folder = uigetdir();
            if isequal(folder, 0)
                return
            end

            file = inputdlg('file name:');
            if isempty(file)
                return
            end
                    
            allEvents = BstUtility.instance.getEvents(obj.sFiles);
            
            eventDescription = struct();
            for i = 1:length(allEvents)
                eventDescription.(replace(allEvents{i}, ' ', '_')) = 'Enter Event Description';
            end
            
            filePath = fullfile(folder, strcat(file{1}, '.json'));
            Utility.saveToJsonFile(filePath, eventDescription);
            
            open(filePath);
            
            waitfor(msgbox('Enter your event description and click OK. The BIDS export will the continue... :)'));
                
            obj.setEventDescriptionFilePath(filePath);
            
        end
             
        function setEventDescriptionFilePath(obj, filePath)
           
            obj.EventDescriptionFilePath = filePath;            
            
        end
        
        function eventStructure = getEventDescription(obj)

            eventStructure = struct.empty();
            obj.askIfEventStructureExists;
            
        end
        
        function askIfEventStructureExists(obj)
            
            EventStructureExists = questdlg(['Do you already have a file with your '...
                            'event description ?'], 'Export to BIDS');

            switch EventStructureExists
                case 'Yes'
                    obj.askToSelectAndSetEventDescriptions;
                    
                case 'No'
                    obj.askToCreateAndSetEventDescriptions;
                    
                case 'Cancel'
                    return
            end
            
        end
        
        function askToSelectAndSetEventDescriptions(obj)
            
            [file, folder] = uigetfile({'*.json'}, pwd);
            if isequal(file, 0)
                return
            end
            
            obj.setEventDescriptionFilePath(fullfile(folder, file));
                    
        end

        function askToCreateAndSetEventDescriptions(obj)
            
            createEventDescriptions = questdlg('Do you want to create it?', 'Export to BIDS');
                    
            switch createEventDescriptions
                case 'Yes'
                    obj.createEventDescriptionsFile;

                otherwise
                    obj.setEventDescriptionFilePath(char.empty);
            end
                    
        end

    end
    
end