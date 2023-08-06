function components = ic_selection(classes, probs)
    [max_prob, max_classes_idx] = max(probs, [], 2);
    max_classes = classes(max_classes_idx);

    % Select component based on criteria
    components = [];
    for iComponent = 1:length(max_prob)
        component_max_class = max_classes{iComponent};
        component_max_prob = max_prob(iComponent);
        if component_max_prob > 0.9 && ~strcmpi(component_max_class, 'Other')
            disp(...
            ['IC_LABEL> Selecting component ' num2str(iComponent) ': ' ...
            component_max_class ' - ' num2str(component_max_prob)]);
            components(end+1) = iComponent;
        end
    end
end