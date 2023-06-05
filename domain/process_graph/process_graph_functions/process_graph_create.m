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
    for iNode = 1:length(s.Nodes)
        processes{iNode} = process_create(s.Nodes(iNode).Process); 
        graph = graph.add_node(processes{iNode});
    end
    %if isfield(s.Edges, 'EndNodes')
        %edges = [s.Edges.EndNodes];
    %end
    if isfield(s, 'Edges')
        edges = [s.Edges.EndNodes];
        edges = reshape(edges, 1, []);
    else
        edges = repelem(1:length(s.Nodes), 2);
        edges = edges(2:end-1);
    end
    for i = 1:2:length(edges)
        graph.Digraph = graph.Digraph.addedge(edges(i), edges(i+1));
    end
end