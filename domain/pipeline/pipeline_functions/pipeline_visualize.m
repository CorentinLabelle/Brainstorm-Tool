function pipeline_visualize(pipeline)
    plot_graph(pipeline);
end

function plot_graph(pipeline)
    [g, names] = get_graph(pipeline);
    g.Nodes.Name = names';
    h = plot(g);
    h.NodeFontAngle = 'normal';
end

function [g, node_names] = get_graph(pipeline, g, start_index, node_names)
    arguments
        pipeline Pipeline
        g = digraph();
        start_index = 0;
        node_names = {};
    end
    for i = 1:pipeline.get_number_of_process()
        number_of_nodes = height(g.Nodes);
        target_index = number_of_nodes + 1;
        if number_of_nodes == 0
            g = g.addnode(1);
        else
            if start_index == 0
                source_index = number_of_nodes;
            else
                source_index = start_index;
                start_index = 0;
            end
            g = g.addedge(source_index, target_index);
        end
        process_name = process_unformat_name(pipeline.get_process(i).get_name());
        node_name = [num2str(target_index) '. ' process_name];
        node_names{end+1} = node_name;
        if pipeline.branch_exists(i)
            branch = pipeline.get_branch(i);
            [g, node_names] = get_graph(branch.get_pipeline(), g, target_index, node_names);
            start_index = target_index;
        end
    end
end

function [g, node_names] = get_graph_from_cell(cell)
    
end