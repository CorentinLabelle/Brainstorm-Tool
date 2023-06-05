function option = option_create(name, option_structure)
    option_type = option_structure.Type;        
    comment = char.empty();
    if isfield(option_structure, 'Comment')
        comment = option_structure.Comment;
    end
    value = double.empty();
    if isfield(option_structure, 'Value')
        value = option_structure.Value;
    end
    default_arguments = {name, value, comment, option_type};
    switch lower(option_type)
        case {  'radio_linelabel', 'text', ...
                'checkbox', 'subjectname', ...
                'radio_label', 'radio', 'channelname', ...
                'textarea', 'atlas'}
            option = Option(default_arguments{:}); 
        case {'value', 'timewindow', 'baseline', 'range', 'poststim'}
            option = ValueOption(default_arguments{:});
        case {'datafile', 'filename'}
            option = DatafileOption(default_arguments{:});  
        case 'combobox_label'
            option = ComboBoxLabelOption(default_arguments{:});
        case 'radio_line'
            option = RadioLineOption(default_arguments{:});
        case 'editpref'
            option = EditOption(default_arguments{:});
        case 'combobox'
            option = ComboBoxOption(default_arguments{:});
        case {'label'}
            option = LabelOption(default_arguments{:}); 
        case {'separator'}                    
            option = SeparatorOption(default_arguments{:});
        case {'button'}
            option = ButtonOption(default_arguments{:});

        % TO manage
        case {  'scout_confirm', 'scout', 'freqrange_static', ...
                'freqsel', 'cluster', 'freqrange', 'groupbands', ...
                'montage', 'event_ordered', 'event'}
            option = Option(default_arguments{:});
        case {'ignore'}
            option = []; 
        otherwise
            error(option_type);
    end
end