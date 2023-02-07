function parameters = RemoveSimultaneaousEventsParameter()
    p1 = ParameterFactory.create('event_to_remove', 'char', char.empty());
    p2 = ParameterFactory.create('event_to_target', 'char', char.empty());
    parameters = ListOfParameters({p1, p2});
end