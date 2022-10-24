classdef BidsFileCreator < handle
    
    methods (Static, Access = public)
        
        function createEventFile(sFile, filePath)
            BidsFileCreator.createFile(@CreateEventVar, sFile, filePath)
        end
        
        function createEventMetaDataFile(sFile, filePath, eventDescriptorPath)
            BidsFileCreator.createFile(@CreateEventMetaDataVar, sFile, filePath, eventDescriptorPath)
        end
        
        function createProvenanceFile(sFile, filePath)
            BidsFileCreator.createFile(@CreateProvenanceVar, sFile, filePath)
        end
        
        function createElectrodeFile(sFile, filePath)
            BidsFileCreator.createFile(@CreateElectrodeVar, sFile, filePath)
        end
        
        function createChannelFile(sFile, filePath)
            BidsFileCreator.createFile(@CreateChannelVar, sFile, filePath)
        end
        
        function createCoordinateSystemFile(sFile, filePath)
            BidsFileCreator.createFile(@CreateCoordinateVar, sFile, filePath)
        end
        
    end
    
    methods (Static, Access = private)
       
        function createFile(varCreatorHandle, sFile, filePath, eventDescriptorPath)
            arguments
                varCreatorHandle
                sFile
                filePath
                eventDescriptorPath = double.empty()
            end
            if isempty(eventDescriptorPath)
                variable = varCreatorHandle(sFile);
            else
                variable = varCreatorHandle(sFile, eventDescriptorPath);
            end
            fileSaver = FileSaver();
            fileSaver.save(filePath, variable);            
        end
        
    end
    
end