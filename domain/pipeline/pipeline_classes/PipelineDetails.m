classdef PipelineDetails < Details
    
    properties (Dependent, GetAccess = public)
        Hash (1,1) string;        
    end
    
    properties (SetAccess = protected, GetAccess = public)
        Folder (1,1) string = strings(1,1);
        Extension (1,1) string = strings(1,1);
        History (1,1);
    end
    
    properties (Constant, GetAccess = public)
        SupportedExtension = [".mat", ".json"];
        BrainstormVersion = PipelineDetails.getBrainstormVersion();       
    end
    
    methods (Access = ?Pipeline)

        function obj = PipelineDetails()
            obj.Folder = strings(1,1);
            obj.Extension = strings(1,1);
            obj.History = PipelineHistory();
        end
        
        function obj = setFolder(obj, folder)
            assert(ischar(folder) || isstring(folder));
            obj.Folder = folder;
        end
        
        function obj = setExtension(obj, extension)
            assert(ischar(extension) || isstring(extension));
            obj.Extension = extension;
        end
        
        function obj = setFile(obj, file)
            assert(ischar(file) || isstring(file));            
            [folder, name, extension] = fileparts(file);            
            if ~isequal(name, "")
                obj.setName(name);
            end            
            if ~isequal(extension, "")
                obj.setExtension(extension);
            end            
            if ~isequal(folder, "")
                obj.setFolder(folder);
            end
        end
        
        function hash = getHash(obj)
            hash = obj.Hash;
        end
        
        function obj = addEntryToHistory(obj, pipeline, varargin)
            obj.History = obj.History.addEntry(pipeline, varargin);
        end
        
        function isEmpty = isEmpty(obj)
            isEmpty = ...
                isequal(obj.Name, strings(1,1)) & ...
                isequal(obj.Folder, strings(1,1)) & ...
                isequal(obj.Extension, strings(1,1)) & ...
                isequal(obj.Documentation, 'No Documentation');            
        end
        
    end
    
    methods (Access = private)
       
        function verifyExtension(obj, extension)
            if ~contains(obj.SupportedExtension, extension)
                error(['Extension is invalid ("' extension '").'])
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
        
        function extensions = formatExtension(extensionToFormat)
            extensions = lower(extensionToFormat);
            for i = 1:length(extensions)
                if ~isequal(extensions{i}(1), '.')
                    extensions(i) = strcat('.', extensions(i));
                end
            end
        end
        
    end
        
    % set and get methods
    methods
        
        function obj = set.Folder(obj, folder)
            obj.Folder = folder;
        end
        
        function obj = set.Extension(obj, extension)
            if ~isequal(extension, strings(1,1))
                extension = PipelineDetails.formatExtension(extension);
                obj.verifyExtension(extension);
            end
            obj.Extension = extension;            
        end
        
        function hash = get.Hash(obj)
            hash = strcat(datestr(obj.DateOfCreation, 'yyyymmddTHHMMSS'), '_', obj.getName());
        end
        
    end
        
end