function EEG = create_event_fields(sFile, EEG)
    if nargin == 1
        EEG = struct();
    end
    event_struct = sFile_get_event_structure(sFile);
    EEG.event = create_event_field(event_struct);
    EEG.urevent = [];
    EEG.epoch = [];
    EEG.eventdescription = [];
    EEG.epochdescription = [];
end

function event = create_event_field(event_struct)
    event = [];
    for iEvent = 1:length(event_struct)
        current_event = event_struct(iEvent);
        for iTime = 1:length(current_event.times)
            idx = length(event) + 1;
            event(idx).type = current_event.label;
            event(idx).latency = current_event.times(iTime);
            event(idx).epoch = current_event.epochs(iTime);
            event(idx).duration = double.empty;
        end        
    end
    table = struct2table(event);
    sorted_table = sortrows(table, 'latency');
    event = table2struct(sorted_table);
end