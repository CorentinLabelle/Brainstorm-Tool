function graph = process_graph_create(input)
    arguments
        input = [];
    end
    if isempty(input)
        graph = ProcessGraph();
        return
    end
    switch class(input)
        case 'struct'
            graph = from_struct(input);
        otherwise
            error('Invalid Input');
    end    
end

function graph = from_struct(s)
    graph = ProcessGraph();
    processes = cell(1, length(s.Nodes));
    for i = 1:length(s.Nodes)
        processes{i} = process_create(s.Nodes(i).Process); 
        graph = graph.add_node(processes{i});
    end
    edges = [];
    if isfield(s.Edges, 'EndNodes')
        edges = [s.Edges.EndNodes];
    end
    for i = 1:2:length(edges)
        graph.Digraph = graph.Digraph.addedge(edges(i), edges(i+1));
    end
end