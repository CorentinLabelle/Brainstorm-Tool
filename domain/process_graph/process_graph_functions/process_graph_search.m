function node_ids = process_graph_search(process_graph, start_index)    
    node_ids = bfsearch(process_graph.Digraph, start_index, 'Restart', true);   