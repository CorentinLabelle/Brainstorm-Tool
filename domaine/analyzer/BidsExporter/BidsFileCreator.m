classdef BidsFileCreator < handle
    
    methods (Access = public)
        
        function createEventFile(obj, sFile, filePath)
            obj.createFile(@CreateEventVar, sFile, filePath)
        end
        
        function createEventMetaDataFile(obj, sFile, filePath)
            obj.createFile(@CreateEventMetaDataVar, sFile, filePath)
        end
        
        function createProvenanceFile(obj, sFile, filePath)
            obj.createFile(@CreateProvenanceVar, sFile, filePath)
        end
        
        function createElectrodeFile(obj, sFile, filePath)
            obj.createFile(@CreateElectrodeVar, sFile, filePath)
        end
        
        function createChannelFile(obj, sFile, filePath)
            obj.createFile(@CreateChannelVar, sFile, filePath)
        end
        
        function createCoordinateSystemFile(obj, sFile, filePath)
            obj.createFile(@CreateCoordinateVar, sFile, filePath)
        end
        
    end
    
    methods (Static, Access = private)
       
        function createFile(varCreatorHandle, sFile, filePath)
           
            variable = varCreatorHandle(sFile);
            fileSaver = FileSaver();
            fileSaver.save(filePath, variable);
            
        end
        
    end
    
end