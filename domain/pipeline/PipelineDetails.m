classdef PipelineDetails
    
    properties (Dependent, GetAccess = public)
        Hash;        
    end
    
    properties (SetAccess = protected, GetAccess = public)
        Name
        Folder
        Extension
        Date_Of_Creation
        Documentation
    end
    
    properties (Constant, GetAccess = public)
        Supported_Extensions = [".mat", ".json"];
        BrainstormVersion = PipelineDetails.getBrainstormVersion();       
    end
    
    methods (Access = public)
        
        function obj = PipelineDetails()
            obj.Name = char.empty();
            obj.Folder = char.empty();
            obj.Extension = char.empty();
            obj.Date_Of_Creation = datetime;
            obj.Documentation = char.empty();
        end
        
        function obj = set_name(obj, name)
            obj.Name = name;
        end
        
        function name = get_name(obj)
            name = obj.Name;
        end
        
        function obj = set_folder(obj, folder)
            obj.Folder = folder;
        end
        
        function folder = get_folder(obj)
            folder = obj.Folder;
        end
        
        function obj = set_extension(obj, extension)
            obj.Extension = extension;
        end
        
        function extension = get_extension(obj)
            extension = obj.Extension;
        end
        
        function obj = set_date(obj, date)
            obj.Date_Of_Creation = date;
        end
        
        function date = get_date(obj)
            date = obj.Date_Of_Creation;
        end
        
        function obj = set_documentation(obj, documentation)
            obj.Documentation = documentation;
        end
        
        function documentation = get_documentation(obj)
            documentation = obj.Documentation;
        end
        
        function hash = getHash(obj)
            hash = obj.Hash;
        end
        
        function bool = is_empty(obj)
            bool = ...
                isempty(obj.Name) & ...
                isempty(obj.Folder) & ...
                isempty(obj.Extension)& ...
                isempty(obj.Documentation);           
        end
        
    end
    
    methods (Access = private)
       
        function valid = is_extension_valid(obj, extension)
            valid = 1;
            if ~contains(obj.Supported_Extensions, extension)
                valid = 0;
            end            
        end
        
    end
    
    methods (Static, Access = private)
        
        function bstVersion = getBrainstormVersion()
            isBrainstormRunning = brainstorm('status');
            if ~isBrainstormRunning
                error('Brainstorm should be running!');
            end
            bstVersion = bst_get('Version');
        end
        
        function extension = format_extension(extension)
            extension = lower(extension);
            if ~startsWith(extension, '.')
                extension = ['.' extension];
            end
        end
        
    end
        
    methods
        
        function obj = set.Name(obj, name)
            if ischar(name) || isstring(name)
                obj.Name = char(name);
            else
                warning('Invalid name.');
            end
        end 
        
        function obj = set.Folder(obj, folder)
            if ischar(folder) || isstring(folder)
                obj.Folder = char(folder);
            else
                warning('Invalid folder.');
            end
        end     
        
        function obj = set.Extension(obj, extension)
            if ~ischar(extension) && ~isstring(extension)
                warning('Invalid extension.');
                return
            end
            extension = PipelineDetails.format_extension(extension);
            if obj.is_extension_valid(extension)
                obj.Extension = char(extension);
            else
                warning(['Invalid extension ("' extension '").']);
            end
        end
        
        function obj = set.Date_Of_Creation(obj, date)
            try 
                date = datetime(date);
                obj.Date_Of_Creation = date;
            catch                
                warning('Invalid date.');
            end
        end
        
        function obj = set.Documentation(obj, documentation)
            if ischar(documentation) || isstring(documentation)
                obj.Documentation = char(documentation);
            else
                warning('Invalid documentation.');
            end
        end
        
        function hash = get.Hash(obj)
            hash = [datestr(obj.Date_Of_Creation, 'yyyymmddTHHMMSS') '_' obj.get_name()];
        end
        
    end
        
end