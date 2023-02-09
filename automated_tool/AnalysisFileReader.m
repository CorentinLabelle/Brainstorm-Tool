classdef AnalysisFileReader
    
    properties
        AnalysisFileFolder
        AnalysisFileName
        AnalysisFileExtension
        JsonStructure
    end
    
    methods (Access = public)
        
        function obj = AnalysisFileReader(jsonFile)
            AnalysisFileReader.verifyFileExtension(jsonFile);
            [obj.AnalysisFileFolder, obj.AnalysisFileName, obj.AnalysisFileExtension] = fileparts(jsonFile);
            obj.JsonStructure = FileReader.read(jsonFile);
        end
        
        function protocol = getProtocol(obj)
            protocol = obj.JsonStructure.Protocol;
        end
        
        function sFile = getSFile(obj)
            sFile = obj.JsonStructure.Dataset;
        end
        
        function pipeline = getPipeline(obj)
            pipelinePath = obj.JsonStructure.Pipeline;
            pipelineAbsolutePath = PathTransformer.toAbsolute(obj.AnalysisFileFolder, pipelinePath);
            pipeline = Pipeline(pipelineAbsolutePath);
        end
        
    end
    
    methods (Static, Access = private)
       
        function verifyFileExtension(filePath)
            [~, ~, extension] = fileparts(filePath);
            assert(strcmpi(extension, '.json'));
        end       
        
    end
end