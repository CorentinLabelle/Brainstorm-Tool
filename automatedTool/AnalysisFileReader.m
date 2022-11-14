classdef AnalysisFileReader
    
    properties
        JsonStructure
    end
    
    methods (Access = public)
        
        function obj = AnalysisFileReader(jsonFile)
            AnalysisFileReader.verifyFileExtension(jsonFile);
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
        
    end
    
    methods (Static, Access = private)
       
        function verifyFileExtension(filePath)
            [~, ~, extension] = fileparts(filePath);
            assert(strcmpi(extension, '.json'));
        end
        
    end
end