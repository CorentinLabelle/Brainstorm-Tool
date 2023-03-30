classdef ProcessGraph
    
    properties (GetAccess = public, SetAccess = public)
        Digraph;
        Search = @bfsearch;
    end
    
    methods (Access = public)
        
        function obj = ProcessGraph()
            obj.Digraph = digraph();
        end
        
        function num_process = get_number_of_process(obj)
            num_process = obj.Digraph.numnodes;
        end
        
        function obj = add_comment(obj, id_or_process, comment)
            node_id = obj.to_node_id(id_or_process);
            node = obj.get_node(node_id);
            node = node.set_comment(comment);
            obj = obj.set_node(node, node_id);
        end
        
        function [obj, node_index] = add_node(obj, process)
            node = Node(process);
            node_table = table(node, 'VariableNames', {'Nodes'});
            obj.Digraph = obj.Digraph.addnode(node_table);            
            node_index = obj.Digraph.numnodes;
        end
        
        function obj = remove_node(obj, id_or_process)
            node_ids = obj.to_node_id(id_or_process);
            obj.Digraph = obj.Digraph.rmnode(node_ids);
        end
        
        function obj = delete_input(obj, id_or_process, input_id_or_process)
            node_id = obj.to_node_id(id_or_process);
            input_node_ids = obj.to_node_id(input_id_or_process);
            pre_edges = obj.get_edge_id(input_node_ids, node_id);
            obj.Digraph = obj.Digraph.rmedge(pre_edges);
        end
        
        function obj = delete_output(obj, id_or_process, output_id_or_process)
            node_id = obj.to_node_id(id_or_process);
            output_node_ids = obj.to_node_id(output_id_or_process);
            post_edges = obj.get_edge_id(node_id, output_node_ids);
            obj.Digraph = obj.Digraph.rmedge(post_edges);
        end
        
        function obj = add_edge(obj, id_or_process_1, id_or_process_2)
            node_id_1 = obj.to_node_id(id_or_process_1);
            node_id_2 = obj.to_node_id(id_or_process_2);
            src = repelem(node_id_1, 1, length(node_id_2));
            trg = repmat(node_id_2, 1, length(node_id_1));
            nb_edge = length(src);
            edge_id = zeros(1, nb_edge);
            for i = 1:nb_edge
                edge = table([src(i) trg(i)], Edge(), 'VariableNames', {'EndNodes', 'Edges'});
                obj.Digraph = obj.Digraph.addedge(edge);   
                edge_id(i) = obj.Digraph.numnodes;
            end  
        end
        
        function obj = force_input(obj, id_or_process, forced_input)
            node_id = obj.to_node_id(id_or_process);
            node = obj.get_node(node_id);
            node = node.set_forced_input(forced_input);
            obj = obj.set_node(node, node_id);
        end
        
        function obj = force_output(obj, id_or_process, forced_output)
            node_id = obj.to_node_id(id_or_process);
            node = obj.get_node(node_id);
            node = node.set_forced_output(forced_output);
            obj = obj.set_node(node, node_id);
        end
        
        function obj = deactivate_node(obj, index_or_process)
            node_index = obj.to_node_id(index_or_process);
            all_children_ids = obj.search(node_index);
            edge_ids = obj.get_edge_id(all_children_ids, all_children_ids);
            obj = obj.deactivate_nodes(all_children_ids);
            obj = obj.deactivate_edges(edge_ids);
        end
        
        function obj = activate_node(obj, index_or_process)
            node_index = obj.to_node_id(index_or_process);
            all_children_ids = obj.Search(obj.Digraph, node_index);
            edge_ids = obj.get_edge_id(all_children_ids, all_children_ids);
            obj = obj.activate_nodes(all_children_ids);
            obj = obj.activate_edges(edge_ids);
        end

        function h = plot(obj)
            nodes = obj.get_all_nodes();
            names = cell(1, length(nodes));
            for i = 1:length(nodes)
                names{i} = [num2str(i) '. ' nodes(i).get_name()];
            end
            obj.Digraph.Nodes.Name = names';
            h = plot(obj.Digraph);
        end
        
        function [obj, output] = run(obj, sFilesIn_original)
            obj.sort_nodes();
            for iNode = 1:obj.get_number_of_process()
                node = obj.get_node(iNode);
                if ~node.is_active()
                    continue
                end
                if iNode == 1 || isempty(obj.Digraph.predecessors(iNode))
                    sFilesIn = sFilesIn_original;
                else
                    sFilesIn = obj.get_input(iNode);
                end
                node = node.run(sFilesIn);
                obj = obj.set_node(node, iNode);
            end
            output = obj.get_output();
        end
        
        %% Json Encoding
        function json = jsonencode(obj, varargin)
            s = struct();
            s.Nodes = struct('ID', 'Process');
            for i = 1:obj.get_number_of_process()
                s.Nodes(i).ID = i;
                s.Nodes(i).Process = obj.get_node(i).get_process();
            end
            s.Edges = obj.Digraph.Edges;
            json = jsonencode(s, varargin{:});
        end
        
    end
    
    methods (Access = private)
        %% Getter
        function node = get_node(obj, node_ids)
            node = obj.Digraph.Nodes{node_ids, 'Nodes'}';
        end
        
        function nodes = get_all_nodes(obj)
            nodes = obj.Digraph.Nodes{:, 'Nodes'}';
        end
        
        function edge = get_edge(obj, edge_ids)
            edge = obj.Digraph.Edges{edge_ids, 'Edges'}';
        end
        
        function edges = get_all_edges(obj)
            edges = obj.Digraph.Edges{:, 'Edges'}';
        end
        
        function edge_ids = get_edge_id(obj, source, target)
            if isempty(source)
                source = 1:obj.Digraph.numnodes;
            end
            if isempty(target)
                target = 1:obj.Digraph.numnodes;
            end
            src = repelem(source, 1, length(target));
            trg = repmat(target, 1, length(source));
            edge_ids = findedge(obj.Digraph, src, trg)';
            edge_ids = edge_ids(edge_ids ~= 0);
        end
               
        function node_ids = get_inactive_nodes(obj)
            node_ids = find(~obj.get_node().is_activated());
        end
        
        function edge_ids = get_inactive_edges(obj)
            edge_ids = find(~obj.get_edge().is_activated());
        end
        
        %% Setter
        function obj = set_node(obj, nodes, node_ids)
            obj.Digraph.Nodes{node_ids, 'Nodes'} = nodes';
        end
        
        function obj = set_edge(obj, edges, edges_ids)
            obj.Digraph.Edges{edges_ids, 'Edges'} = edges';
        end
       
        %% Activate/Deactivate
        function obj = deactivate_nodes(obj, node_ids)
            nodes = obj.get_node(node_ids);
            nodes = nodes.deactivate();
            obj = obj.set_node(nodes, node_ids);
        end
        
        function obj = activate_nodes(obj, node_ids)
            nodes = obj.get_node(node_ids);
            nodes = nodes.activate();
            obj = obj.set_node(nodes, node_ids);
        end
        
        function obj = deactivate_edges(obj, edge_ids)
            edges = obj.get_edge(edge_ids);
            edges = edges.deactivate();
            obj = obj.set_edge(edges, edge_ids);
        end
        
        function obj = activate_edges(obj, edge_ids)
            edges = obj.get_edge(edge_ids);
            edges = edges.activate();
            obj = obj.set_edge(edges, edge_ids);
        end
        
        %% Search graph
        function nodes = search(obj, node_index)
            nodes = obj.Search(obj.Digraph, node_index)';
        end

        function obj = sort_nodes(obj)
            sorted_indexes = obj.Search(obj.Digraph, 1, 'Restart', true);
            obj.Digraph = obj.Digraph.reordernodes(sorted_indexes);          
        end

        %% To node id
        function node_id = to_node_id(obj, input)
            if isnumeric(input)
                node_id = input;
            elseif isa(input, 'Process')
                node_id = obj.process_to_node_id(input);
            elseif iscell(input)
                node_id = zeros(1, length(input));
                for i = 1:length(input)
                    node_id(i) = obj.to_node_id(input{i});
                end
            end
        end
        
        function node_id = process_to_node_id(obj, process)
            nodes = obj.get_all_nodes();
            node_id = find(nodes.get_process() == process);
            if ~isscalar(node_id)
                node_id = node_id(end);
                warning(['The source process is duplicated.' newline ...
                        'The source process chosen is the later one.' newline ...
                        'Advice, use the process index to select the right process.']);
            end
        end
        
        %% Get input
        function sFilesIn = get_input(obj, node_index)
            pre_ids = obj.Digraph.predecessors(node_index);
            nodes = obj.get_node(pre_ids);
            sFilesIn = nodes.get_output();
        end
        
        %% Get output of graph
        function output = get_output(obj)
            obj.sort_nodes();
            output = [];
            for i = 1:obj.Digraph.numnodes
                if isempty(obj.Digraph.successors(i))
                    node = obj.get_node(i);
                    output = [output node.get_output()];
                end
            end
        end
        
        %% Separate node from graph
        function obj = separate_node_from_graph(obj, node_index)
            pre_ids = obj.Digraph.predecessors(node_index);
            suc_ids = obj.Digraph.successors(node_index);
            pre_edges = obj.get_edge_id([], node_index);
            post_edges = obj.get_edge_id(node_index, []);            
            obj.Digraph = obj.Digraph.rmedge([pre_edges post_edges]);            
            obj.Digraph = obj.Digraph.addedge(pre_ids, suc_ids);
        end
    end
    
end