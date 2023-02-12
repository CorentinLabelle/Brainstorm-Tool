classdef Configuration
    
    properties (GetAccess = public, SetAccess = private)
        Structure = struct( 'DataPath', char.empty(), ...
                            'PipelinePath', char.empty(), ...
                            'AnalysisFilePath', char.empty());
        ConfigurationFolder = '~/.config/brainstorm_tool/';
        ConfigurationFilename = 'brainstorm_tool_config.json';
    end
    
    methods (Access = public)
        
        function save(obj)
            if ~isConfigurationValid(obj)
                warning('Configuration Invalid.');
                return
            end
            if ~isfolder(obj.ConfigurationFolder)
                obj.createFolder();
            end
            fullpath = obj.getFullPath();
            FileSaver.save(fullpath, obj.Structure);
        end
       
        function obj = loadConfiguration(obj)
            fullpath = obj.getFullPath();
            if ~isfile(fullpath)
                obj = obj.createConfiguration();
            else
                obj.Structure = FileReader.read(fullpath);
            end
        end
        
        function fullpath = getFullPath(obj)
            fullpath = fullfile(obj.ConfigurationFolder, obj.ConfigurationFilename);
        end
        
        function bool = isDataPathEmpty(obj)
            bool = isempty(obj.Structure.DataPath);
        end
        
        function bool = isPipelinePathEmpty(obj)
            bool = isempty(obj.Structure.PipelinePath);
        end
        
        function dataPath = getDataPath(obj)
            dataPath = obj.Structure.DataPath;
        end
        
        function pipelinePath = getPipelinePath(obj)
            pipelinePath = obj.Structure.PipelinePath;
        end
        
        function analysisFilePath = getAnalysisFilePath(obj)
            analysisFilePath = obj.Structure.AnalysisFilePath;
        end
        
        function obj = askToSelectDataPath(obj)
            dataPath = uigetdir('', 'Select DATA folder');
            obj.Structure.DataPath = dataPath;
        end
        
        function obj = askToSelectAnalysisFilePath(obj)
            analysisFilePath = uigetdir('', 'Select ANALYSIS FILE folder');
            obj.Structure.AnalysisFilePath = analysisFilePath;
        end
        
        function obj = askToSelectPipelinePath(obj)
            pipelinePath = uigetdir('', 'Select PIPELINE folder');
            obj.Structure.PipelinePath = pipelinePath;
        end
        
        function bool = doesFileExist(obj)
            bool = isfile(obj.getFullPath());
        end
        
        function obj = createConfiguration(obj)
            waitfor(msgbox(Configuration.getMessage(), Configuration.getTitle()));
            obj = obj.askToSelectDataPath();
            obj = obj.askToSelectPipelinePath();
            obj = obj.askToSelectAnalysisFilePath();
            obj.save();
        end
        
    end
    
    methods (Access = private)
        
        function createFolder(obj)
            mkdir(obj.ConfigurationFolder);
        end
        
        function bool = isConfigurationValid(obj)
            condition1 = ~any(structfun(@isempty, obj.Structure));
            condition2 = all(structfun(@ischar, obj.Structure));
            bool = condition1 && condition2;
        end
    
    end
    
    methods (Static, Access = private)
        
        function msg = getMessage()
            msg = sprintf(...
                ['To create a configuration, you have to select:' newline ...
                '- A data folder' newline ...
                '- A pipeline folder' newline ...
                '- An analysis file folder']);
        end
        
        function title = getTitle()
            title = 'Creating Configuration';
        end
        
    end
    
end

