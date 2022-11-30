classdef EventManager
    
    methods (Static, Access = public)
        
        function allEvents = getAllEvents(sFiles)
            allEvents = string.empty();
            for i = 1:length(sFiles)                
                eventsStruct = EventManager.loadEventStruct(sFiles(i));
                for j = 1:length(eventsStruct)
                    if ~any(strcmpi(allEvents, eventsStruct(j).label))
                        allEvents = [allEvents string(eventsStruct(j).label)];
                    end
                end
            end
        end
        
        function event = getEvent(sFile, name)
            eventsStruct = EventManager.loadEventStruct(sFile);
            for i = 1:length(eventsStruct)
               if isequal(eventsStruct(i).label, char(name))
                   event = eventsStruct(i);
                   return
               end
            end
        end
        
        function times = getTimeOfEvent(sFile, name)
            event = EventManager.getEvent(sFile, name);
            times = event.times;
        end
        
    end
    
    methods (Static, Access = private)
        
        function eventsStruct = loadEventStruct(sFile)
            studyFile = load(SFileManager.getStudyPathFromSFile(sFile));
            eventsStruct = studyFile.F.events;
        end
        
    end
    
end