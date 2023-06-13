classdef Pipeline < handle
    
    properties (SetAccess = private, GetAccess = public)
        Details;
        History;
        Graph;
    end

    methods (Access = public)
%% Constructor
        function obj = Pipeline()
            obj.Details = PipelineDetails();
            obj.History = PipelineHistory();
            obj.Graph = process_graph_create();
        end
        
%% Getters        
        function folder = get_folder(obj)
            folder = obj.Details.get_folder;
        end
        
        function name = get_name(obj)
            name = obj.Details.get_name();
        end
                  
        function extension = get_extension(obj)
            extension = obj.Details.get_extension;
        end
               
        function date = get_date(obj)
            date = obj.Details.get_date(); 
        end
        
        function path = get_path(obj, extension)
            arguments
                obj
                extension = obj.get_extension();
            end
            path = fullfile(obj.get_folder(), strcat(obj.get_name(), extension)); 
        end
            
        function documentation = get_documentation(obj)
            documentation = obj.Details.get_documentation;
        end
        
        function process = get_process(obj, index)
            node = obj.Graph.get_node(index);
            process = node.get_process();
        end
        
        function previous_pipeline = get_previous_pipeline(obj)
            previous_pipeline = obj.Details.History.getPreviousPipeline();
        end        
          
        function indexes = get_process_index(obj, process_name)
            fname = process_format_name(process_name);
            indexes = [];
            for i = 1:obj.get_number_of_process()
                process = obj.get_process(i);
                if strcmp(fname, process.get_fname())
                    indexes(end+1) = i;
                end
            end
        end
        
%% Setters        
        function select_folder(obj)
            folder = uigetdir(pwd, 'Select the folder where to save your pipeline!');
            if folder ~= 0
                obj.Details.set_folder(folder);
            end           
        end
        
        function set_folder(obj, folder)
            obj.Details = obj.Details.set_folder(folder);
            obj.History = obj.History.add_entry(folder);
        end

        function set_extension(obj, extension)
            obj.Details = obj.Details.set_extension(extension);
            obj.History = obj.History.add_entry(extension);            
        end

        function set_name(obj, name)
            obj.Details = obj.Details.set_name(name);
            obj.History = obj.History.add_entry(name);
        end
        
        function set_file(obj, file)
            [folder, name, extension] = fileparts(file);            
            if ~isequal(name, "")
                obj.set_name(name);
            end
            if ~isequal(extension, "")
                obj.set_extension(extension);
            end            
            if ~isequal(folder, "")
                obj.set_folder(folder);
            end
        end
        
        function set_date(obj, dateOfCreation)
            obj.Details = obj.Details.set_date(dateOfCreation);
            obj.History = obj.History.add_entry(dateOfCreation); 
        end

        function set_documentation(obj, documentation)
            obj.Details = obj.Details.set_documentation(documentation);
            obj.History = obj.History.add_entry(documentation);           
        end
        
        function set_graph(obj, graph)
            obj.Graph = graph;
        end
        
%% Graph
        function add_comment(obj, id_or_process, comment)
            obj.Graph = obj.Graph.add_comment(id_or_process, comment);
        end

        function node_id = add_node(obj, process)
            [obj.Graph, node_id] = obj.Graph.add_node(process);
        end
        
        function remove_node(obj, id_or_process)
            obj.Graph = obj.Graph.remove_node(id_or_process);
        end
        
        function add_edge(obj, id_or_process, inputs)
            obj.Graph = obj.Graph.add_edge(id_or_process, inputs);
        end
        
        function delete_input(obj, id_or_process, inputs)
            arguments
                obj; id_or_process; inputs = [];
            end
            obj.Graph = obj.Graph.delete_input(id_or_process, inputs);
        end
        
        function delete_output(obj, id_or_process, outputs)
            arguments
                obj; id_or_process; outputs = [];
            end
            obj.Graph = obj.Graph.delete_output(id_or_process, outputs);
        end
        
        function force_input(obj, id_or_process, forced_input)
            obj.Graph = obj.Graph.force_input(id_or_process, forced_input);
        end
        
        function force_output(obj, id_or_process, forced_output)
            obj.Graph = obj.Graph.force_output(id_or_process, forced_output);
        end
        
        function activate_node(obj, index_or_process)
            obj.Graph = obj.Graph.activate_node(index_or_process);
        end

        function deactivate_node(obj, index_or_process)
            obj.Graph = obj.Graph.deactivate_node(index_or_process);
        end

        function number_of_process = get_number_of_process(obj)
        	number_of_process = obj.Graph.get_number_of_process();
        end
        
        function bool = is_empty(obj)
            bool = obj.get_number_of_process() == 0;
        end
      
%% Save
        function save(obj)
            obj.History = obj.History.add_entry(obj.get_path());
            save_file(obj.get_path(), obj);
        end
        
%% Visualize
        function visualize(obj)
            obj.Graph.plot();
        end
        
%% Display
        function disp(obj)
            disp(obj.convert_to_characters());
        end
        
        function pip_as_characters = convert_to_characters(obj)
            pip_as_characters = char(strjoin(obj.convert_to_string(), '\n'));            
        end
        
%% Run
        function sFilesOut = run(obj, sFilesIn, with_report)
            arguments
                obj Pipeline;
                sFilesIn = [];
                with_report = true;
            end
            if with_report
                Report.start(sFilesIn);
            end

            [obj.Graph, sFilesOut] = obj.Graph.run(sFilesIn);
            
            if with_report
                report = Report.save(sFilesOut);
                report.open();
                report_folder = fullfile(obj.get_folder, 'report/');
                report.export(report_folder);
            end
        end
        
%% Check in Pipeline
        function bool = is_process_in(obj, process_name)
            indexes = obj.get_process_index(process_name);
            if isempty(indexes)
                bool = false;
            else
                bool = true;
            end
        end

%% Signature
        function signature = get_signature(obj, input_type)
            obj.Graph = obj.Graph.validate(input_type);
            output_type = obj.Graph.get_output_types();
            input_type = char(strjoin(string(input_type), ', '));
            output_type = char(strjoin(string(output_type), ', '));
            signature = PipelineSignature(input_type, output_type);
        end
        
%         function isEqual = eq(obj, pipeline)
%             isEqual = obj.Processes == pipeline.Processes;
%         end
%         
%         function index = getProcessIndexWithName(obj, processNameToFind)
%             index = obj.Processes.getProcessIndexWithName(processNameToFind);        
%         end
%         
%         function index = getProcessIndex(obj, process)
%             index = obj.Processes.getProcessIndex(process);        
%         end
%         
%         function process = findProcessWithName(obj, name)
%             process = obj.getProcess(obj.getProcessIndexWithName(name));
%         end
%         
%         function isIn = isProcessInPipelineWithName(obj, processName)
%             isIn = obj.Processes.isProcessInWithName(processName);            
%         end
%         
%         function isDefault = isDefault(obj)
%             isDefault = obj.Details.isEmpty() & obj.Processes.isEmpty();            
%         end
%         
%% Json Encoding
        function json = jsonencode(obj, varargin)
            pip_to_json = pipeline_to_json(obj);
            json = jsonencode(pip_to_json, varargin{:});
        end

    end

%% Private Methods
    methods (Access = private)
        
        function History.add_entry(obj, varargin)
            obj.History = obj.History.add_entry(obj, varargin);
        end
        
        function characters = processes_to_characters(obj)
            str = strings(1, obj.get_number_of_process());
            for i = 1:obj.get_number_of_process()
                process = obj.get_process(i);
                str{i} = [num2str(i) '. ' process.to_character()];
            end
            characters = char(strjoin(str, '\n\t'));
        end
        
        function pipAsString = convert_to_string(obj)
            pipAsString = strings(1, 5);
            pipAsString(1) = ['PIPELINE', newline, char(obj.get_name())];
            pipAsString(2) = ['FOLDER', newline, char(obj.get_folder())];
            pipAsString(3) = ['EXTENSION', newline, char(obj.get_extension())];
            pipAsString(4) = ['DATE OF CREATION', newline, char(obj.get_date())];
            pipAsString(5) = ['LIST OF PROCESS', newline, obj.processes_to_characters()];       
        end
        
    end
    
end