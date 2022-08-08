function allEvents = GetAllEvents(sFiles)
    % Extract all events for every study in cFiles (sEvents).
    % Input>    cFiles [struc]
    % Output>   allEvents [cell]: Cell with all events that are
    %                               in at least one study.

    allEvents = string.empty();
    for i = 1:length(sFiles)
        studyFile = load(SFileManager.getStudyPathFromSFile(sFiles(i)));
        eventsStruct = studyFile.F.events;

        for j = 1:length(eventsStruct)
            if ~any(strcmp(allEvents, eventsStruct(j).label))
                allEvents = [allEvents string(eventsStruct(j).label)];
            end
        end
    end

end

