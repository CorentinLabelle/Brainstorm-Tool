classdef EventDescriptorCreator
    
    methods (Static, Access = public)
        
        function eventDescriptorPath = getEventDescriptor(sFile)            
            answer = EventDescriptorCreator.askForEventDescriptor();
            switch answer
                case 'Select'
                    eventDescriptorPath = EventDescriptorCreator.selectEventDescriptor();                    
                case 'Create'
                    eventDescriptorPath = EventDescriptorCreator.createEventDescriptor(sFile);                    
                otherwise
                    eventDescriptorPath = char.empty();
            end
        end
        
    end  
    
    methods (Static, Access = private)
        
        function answer = askForEventDescriptor()            
            answer = questdlg(  'How do you want to access your Event Descriptor file ?', ...
                                'Export to BIDS', ...
                                'Select', ...
                                'Create', ...
                                'No need', 'Select');
        end
        
        function eventDescriptorPath = selectEventDescriptor()            
            [file, folder] = uigetfile({'*.json'}, pwd);
            if isequal(file, 0)
                eventDescriptorPath = char.empty();
                return
            end            
            eventDescriptorPath = fullfile(folder, file);                    
        end
        
        function filePath = createEventDescriptor(sFile)           
            folder = uigetdir();
            if isequal(folder, 0)
                return
            end

            file = inputdlg('File name for your Event Descriptor:');
            if isempty(file)
                return
            end
                    
            allEvents = EventManager.getAllEvents(sFile);
            
            eventDescription = struct();
            for i = 1:length(allEvents)
                eventDescription.(replace(allEvents{i}, ' ', '_')) = 'Enter Event Description';
            end
            
            filePath = fullfile(folder, strcat(file{1}, '.json'));
            FileSaver.save(filePath, eventDescription);
            
            open(filePath);
            
            waitfor(msgbox('Enter your event description and click OK. The BIDS export will the continue... :)'));

        end
        
    end
    
end