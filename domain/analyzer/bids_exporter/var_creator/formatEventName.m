function eventName = formatEventName(eventName)

    % Replace '-' with '_'
    eventName = strrep(eventName, '-', '_');

    % Replace ' ' with '_'
    eventName = strrep(eventName, ' ', '_');

    % Check if character is a digit
    isDigit = isstrprop(eventName, 'digit');

    % If first character is a digit
    if (isDigit(1))
        eventName = "f" + eventName;
    end
    
end