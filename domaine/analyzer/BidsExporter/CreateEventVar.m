function evetnTsvFileAsString = CreateEventVar(sFile)
    % Create TSV file that lists the events with time and duration.

    % Input>    cFiles [cell]
    %           destination [char]: path indicating where to save the TSV file 

    % Load Event structure
    studyMatfile = load(fullfile(BstUtility.getDatabasePath(), bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));
    eventStruct = studyMatfile.F.events;

    % Initialiaze tsvFile variable with titles
    evetnTsvFileAsString = strings([1,3]);
    count = 1;
    evetnTsvFileAsString(count,:) = ["onset" "duration" "trial type"];
    count = count + 1;

    % Loop through every event types
    for i = 1:length(eventStruct)

        % Loop through all time (each occurence of an event)
        for j = 1:length(eventStruct(i).times)

            % Save information in tsvFile variable
            evetnTsvFileAsString(count,:) = [eventStruct(i).times(j) 0 string((eventStruct(i).label))];
            count = count + 1;
        end
    end

end
        
