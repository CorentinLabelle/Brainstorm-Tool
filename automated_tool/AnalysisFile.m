classdef AnalysisFile
    
    properties (SetAccess = private, GetAccess = public)
        FilePath;
        JsonStructure;
        Configuration;
    end
    
    methods (Access = public)
        
        function obj = AnalysisFile(jsonFile)
            obj.Configuration = obj.loadConfiguration();
            AnalysisFile.verifyFileExtension(jsonFile);
            jsonFile = obj.convertAnalysisFilePath(jsonFile);
            obj.FilePath = jsonFile;
            obj.JsonStructure = FileReader.read(jsonFile);
        end
        
        function protocol = getProtocol(obj)
            protocol = obj.JsonStructure.Protocol;
        end
        
        function sFile = getSFile(obj)
            sFile = obj.JsonStructure.Dataset;
        end
        
        function pipeline = getPipeline(obj)
            pipeline = Pipeline(obj.JsonStructure.Pipeline);
        end
        
         function setProtocol(obj, protocol)
            obj.JsonStructure.Protocol = protocol;
        end
        
        function setSFile(obj, sFile)
            if ~isempty(sFile)
                sFile = {sFile.FileName};
            end
            obj.JsonStructure.Dataset = sFile;
        end
        
        function setPipeline(obj, pipeline)
            pipelinePath = pipeline.getPath('.json');
            obj.setPipelinePath(pipelinePath);
        end
        
        function setPipelinePath(obj, pipelinePath)
            obj.JsonStructure.Pipeline = pipelinePath;
        end
        
        function path = saveAnalysisFile(obj, path)
            path = obj.convertAnalysisFilePath(path);
            FileSaver.save(path, obj.JsonStructure);
        end
        
        function outputPath = createOutput(obj, variable)
            outputPath = obj.createOuputPath();
            FileSaver.save(outputPath, variable);
        end
        
    end
    
    methods (Access = private)
        
        function jsonFileAbsolute = convertAnalysisFilePath(obj, jsonFileRelative)
            if ~startsWith(jsonFileRelative, '.')
                jsonFileAbsolute = jsonFileRelative;
            else
                jsonFileAbsolute = fullfile(obj.Configuration.getAnalysisFilePath(), jsonFileRelative);
            end            
        end
        
        function outputPath = createOuputPath(obj)
            [folder, filename] = fileparts(obj.FilePath);
            outputPath = strcat(fullfile(folder, filename), '_output.json');            
        end
        
    end
    
    methods (Static, Access = private)
        
        function configuration = loadConfiguration()
            configuration = Configuration();
            configuration = configuration.loadConfiguration();
        end
        
        function verifyFileExtension(filePath)
            [~, ~, extension] = fileparts(filePath);
            assert(strcmpi(extension, '.json'), ['Invalid Extension (' filePath ').']);
        end
        
    end
    
end

