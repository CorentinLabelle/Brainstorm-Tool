function components = ic_selection(classes, probs, thresholds)
    if nargin < 3 || isempty(thresholds)
        thresholds = get_default_threshold();
    end
    
    [max_prob, max_classes_idx] = max(probs, [], 2);
    max_classes = classes(max_classes_idx);

    % Select component based on criteria
    components = [];
    for iComponent = 1:length(max_prob)
        
        component_max_class = max_classes{iComponent};
        component_max_class = format_class_name(component_max_class);
        if strcmpi(component_max_class, 'Other')
            continue
        end
        class_threshold = thresholds.(component_max_class);
        
        component_max_prob = max_prob(iComponent);
        
        if component_max_prob >= class_threshold
            disp(...
            ['IC_LABEL> Selecting component ' num2str(iComponent) ': ' ...
            component_max_class ' - ' num2str(component_max_prob)]);
        
            components(end+1) = iComponent;
        end
        
    end
end


function default_threshold = get_default_threshold()    
    default_threshold = struct();
    default_threshold.Brain = 0.85;
    default_threshold.Muscle = 0.85;
    default_threshold.Eye = 0.85;
    default_threshold.Line_Noise = 0.85;
    default_threshold.Channel_Noise = 0.85;
end


function modified_class_name = format_class_name(original_class_name)
    modified_class_name = strrep(original_class_name, ' ', '_');
end
