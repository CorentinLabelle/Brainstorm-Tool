function option = option_set_value(option, new_value)

    parameter_type = lower(option.Type);    
    switch parameter_type
       
        case {  'checkbox', 'radio', 'radio_linelabel', ...
                'text', 'textarea', ...
                'channelname', 'subjectname', ...
                'scout', 'scout_confirm', 'atlas', 'editpref', ...
                'radio_label', 'groupbands', 'montage', ...
                'event_ordered', 'event', 'freqsel', 'cluster'}
            option.Value = new_value;
            
        case {  'value', 'timewindow', 'baseline', 'range', ...
                'poststim', 'freqrange_static', 'freqrange'}
            option.Value{1, 1} = new_value;
            
        case {'filename', 'datafile'}
            if ischar(new_value)
                option.Value{1} = new_value;
            elseif iscell(new_value)
                option.Value{1} = new_value{1};
                option.Value{2} = new_value{2};
            end
            
        case {'combobox_label'}
            if ischar(new_value)
                 option.Value{1} = new_value;
            elseif isnumeric(new_value)
                 option.Value =  option.Value{2}(1, new_value);
            end
            
        case {'combobox'}
            possible_values = option.Value{2};
            if ischar(new_value)
                index = find(cellfun(@(x) strcmp(x, new_value), possible_values));
                option.Value{1} = index;
            elseif isnumeric(new_value)
                option.Value{1} = new_value;
            end
            
        case {'radio_line'}
            possible_values = option.Comment;
            if ischar(new_value)
                index = find(cellfun(@(x) strcmp(x, new_value), possible_values));
                option.Value = index;
            elseif isnumeric(new_value)
                option.Value = new_value;
            end
            
        case {'button', 'label', 'separator'}
            % Do nothing
            
        case {'cluster_confirm'}
            % Type of option not used in any process
        
        otherwise
            error(['Unsupporter parameter type: ' parameter_type]);
             
    end
end
