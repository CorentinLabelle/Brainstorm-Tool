function components = ic_selection(classes, probs, thresholds)
%     if nargin < 3 || isempty(thresholds)
%         thresholds = get_default_threshold();
%     end
    
    [max_prob, max_classes_idx] = max(probs, [], 2);
    max_classes = classes(max_classes_idx);

    % Select component based on criteria
    components = [];
    for iComponent = 1:length(max_prob)
        
        component_max_class = max_classes{iComponent};
        component_max_class = strrep(component_max_class, ' ', '_');
        if strcmpi(component_max_class, 'Other')
            continue
        end
        class_threshold = thresholds.(component_max_class);
        
        component_max_prob = max_prob(iComponent);
        
        if component_max_prob >= class_threshold
            disp(...
            ['IC_SELECTION> Selecting component ' num2str(iComponent) ': ' ...
            component_max_class ' - ' num2str(component_max_prob)]);
        
            components(end+1) = iComponent;
        end
        
    end
    
    disp(['IC_SELECTION> Number of component selected: ' num2str(length(components))]);
end
