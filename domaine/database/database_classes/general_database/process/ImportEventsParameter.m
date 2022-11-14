function parameters = ImportEventsParameter()
    p1 = ParameterFactory.create('event', 'cell', cell.empty());
    p1 = p1.setConverterFunction(@convertEventCell);
    p2 = ParameterFactory.create('epoch', 'numeric', double.empty());
    parameters = {p1, p2};
end

function eventAsCharacter = convertEventCell(eventCell)
    eventAsCharacter = strjoin(eventCell, ', ');
end