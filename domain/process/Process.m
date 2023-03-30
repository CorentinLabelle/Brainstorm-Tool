classdef Process < handle
    
    properties (GetAccess = public, SetAccess = private)
        sProcess
        Options
    end
    
    methods (Access = public)
        
        function obj = Process(process_name)
            obj.sProcess = process_load_sProcess(process_name);
            obj.initialize_options();
        end
        
        %% Getter   
        function name = get_name(obj)
            name = obj.get_fname();
        end
        
        function fname = get_fname(obj)
            fname = func2str(obj.sProcess.Function);
        end
        
        function comment = get_comment(obj)
            comment = obj.sProcess.Comment;
        end
        
        function category = get_category(obj)
            category = obj.sProcess.Category;
        end
        
        function subgroup = get_subgroup(obj)
            subgroup = obj.sProcess.SubGroup;
        end
        
        function link = get_link(obj)
            link = obj.sProcess.Description;
            index = strfind(link, 'highlight');
            if ~isempty(index)
                link = link(1:index-1);
            end
            link = strrep(link, ' ', '_');
        end
        
        %% Setter
        function set_option(obj, name_or_index, value)
            index = obj.get_option_index(name_or_index);
            obj.Options{index} = obj.Options{index}.set_value(value);
        end
        
        %% Display
        function disp(obj)
           disp(obj.to_character());
        end
                
        function chars = to_character(obj)
            str = strings(1, length(obj.Options));
            for i = 1:length(obj.Options)
                str{i} = [num2str(i) '. ' obj.Options{i}.to_character()];
            end
            chars = [obj.get_name() newline ...
                    char(strjoin(str, '\n'))];
        end

        %% Run
        function sFilesOut = run(obj, sFilesIn)
            arguments
                obj
                sFilesIn = [];
            end
            process_name_to_display = process_unformat_name(obj.get_fname());
            disp(['STARTING PROCESS> ' process_name_to_display]);
            command = obj.to_command(sFilesIn);
            sFilesOut = eval(command);
            disp(['ENDING PROCESS> ' process_name_to_display]);
        end
        
        function command = to_command(obj, sFile)
            sFilesIn_command = sFile_to_command(sFile);
            command = obj.options_to_command();
            command = [  'bst_process(''CallProcess'', ''' ...
                    obj.get_fname() ''', ' ...
                    sFilesIn_command ', [], ' ...
                    command ');'];
        end
        
        %% Equality
        function bool = eq(obj, process_2)
            array = obj;
            scalar = process_2;
            if isscalar(obj)
                array = process_2;
                scalar = obj;
            end
            bool = false(1, length(array));
            for i = 1:length(array)
                bool(i) = scalar.is_equal(array(i));
            end
        end
        
        %% Json encoding
        function json = jsonencode(obj, varargin)
            s = struct();
            s.Name = obj.get_name();
            for i = 1:length(obj.Options)
                s.Parameters.(obj.Options{i}.Name) = obj.Options{i}.get_value();
            end
            json = jsonencode(s, varargin{:});
        end
          
        %% To cell
        function objAsCell = cell(obj)
            objAsCell = {obj};
        end
    end
    
    methods (Access = private)
        
        function bool = is_equal(obj, process)
            bool = strcmp(obj.to_command([]), process.to_command([]));
        end
        
        function initialize_options(obj)
            options = obj.sProcess.options;
            if isempty(options)
                return
            end
            option_names = fields(options);
            obj.Options = cell(1, length(option_names));
            for i = 1:length(option_names)
                name = option_names{i};
                option = option_create(name, options.(name));
                obj.Options{i} = option;
            end
            obj.Options = obj.Options(~cellfun(@isempty, obj.Options));
        end
        
        function command = options_to_command(obj)
            command = strings(1, length(obj.Options));
            for i = 1:length(obj.Options)
                command{i} = obj.Options{i}.to_command();
            end
            command = char(strjoin(command, ', '));
        end
       
        function index = get_option_index(obj, name_or_index)
            if isnumeric(name_or_index)
                index = name_or_index;
            elseif ischar(name_or_index) || isstring(name_or_index)
                name_or_index = strrep(name_or_index, ' ', '_');
                index = cellfun(@(x) strcmpi(x.get_name(), name_or_index), obj.Options);
                index = find(index);  
            end
            if isempty(index)
                error(['Invalid option: ' name_or_index '.']);
            end
        end
        
    end
    
end