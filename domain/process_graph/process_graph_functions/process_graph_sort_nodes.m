function sorted_nodes = process_graph_sort_nodes(process_graph)

    root_ids = process_graph.get_root_ids();
    
    sorted_nodes = process_graph_search(process_graph, root_ids(1)); 
    
    for i = 2:length(root_ids)
        root_id = root_ids(i);
        index_in_sorted = find(sorted_nodes == root_id);
        sorted_nodes = move_element_in_array(sorted_nodes, index_in_sorted, i);
    end
        
end

function new_array = move_element_in_array(array, init_idx, final_idx)
    element = array(init_idx);
    if init_idx < final_idx
        new_array = [array(1:init_idx-1); array(init_idx+1:final_idx); element; array(final_idx+1:end)];
    elseif init_idx > final_idx
        new_array = [array(1:final_idx-1); element; array(final_idx:init_idx-1); array(init_idx+1:end)];
    else
        new_array = array;
    end
end