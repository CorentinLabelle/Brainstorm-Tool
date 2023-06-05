classdef Node
    
    properties (GetAccess = public, SetAccess = private)
        Process
        Active
        Is_Input_Forced
        Forced_Input
        Is_Output_Forced
        Output
        Comment
    end
    
    methods (Access = public)
        
        function obj = Node(process)
            obj.Process = process;
            obj.Active = true;
            obj.Is_Input_Forced = false;
            obj.Is_Output_Forced = false;
        end
        
        function obj = set_comment(obj, comment)
            comment = char(comment);
            obj.Comment = comment;
        end
        
        function obj = set_forced_input(obj, forced_input)
            obj.Forced_Input = forced_input;
            obj.Is_Input_Forced = true;
        end
        
        function obj = set_forced_output(obj, forced_output)
            obj.Output = forced_output;
            obj.Is_Output_Forced = true;
        end
        
        function name = get_name(obj)
            if isempty(obj.Comment)
                name = obj.Process.get_fname();
            else
                name = obj.Comment;
            end
        end
        
        function bool = is_active(obj)
            bool = false(1, length(obj));
            for i = 1:length(bool)
                bool(i) = obj(i).Active;
            end
        end
        
        function obj = activate(obj)
            for i = 1:length(obj)
                node = obj(i);
                node.Active = true;
                obj(i) = node;
            end
        end
        
        function obj = deactivate(obj)
            for i = 1:length(obj)
                node = obj(i);
                node.Active = false;
                obj(i) = node;
            end
        end
        
        function output = get_output(obj)
            output = [obj.Output]; 
        end
        
        function process = get_process(obj)
            process = [obj.Process];
        end
        
        function obj = run(obj, sFilesIn)
            if obj.Is_Input_Forced
                sFilesIn = obj.Forced_Input;
            end
            output = obj.Process.run(sFilesIn);
            if ~obj.Is_Output_Forced
                obj.Output = output;
            end
        end
        
%% Json Encoding
        function json = jsonencode(obj, varargin)
            s.Process = obj.get_process();
            json = jsonencode(s, varargin{:});
        end
        
    end
    
end