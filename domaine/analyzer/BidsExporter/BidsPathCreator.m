classdef BidsPathCreator < handle
    
    properties (Access = private)
        
        FolderName char = char.empty;
        FolderPath char = char.empty;
        
    end
    
    properties (Constant, GetAccess = private)
        
        SplitCharacter = '_';
        
    end
    
    methods (Access = ?BidsExporter)
        
        function obj = BidsPathCreator(bidsFolderPath)
           
            [folderPath, folderName] = fileparts(bidsFolderPath);
            
            obj.FolderPath = folderPath;
            obj.FolderName = folderName;
            
            obj.createValidFolderName();
                                    
        end
        
        function bidsPath = getValidBidsPath(obj)
            
            bidsPath = fullfile(obj.FolderPath, obj.FolderName);
            
        end
         
        function provenanceFilePath = getProvenanceFilePath(obj, sFile)
           
            tag = BidsFileTagGetter.getProvenanceTag();
            extension = BidsFileExtensionGetter.getProvenanceExtension();
            
            studyName = strcat(obj.getStudyName(sFile), tag, extension);
            
            provenanceFilePath = fullfile(obj.getDerivativePath(), studyName);
            
        end
        
        function eventFilePath = getEventFilePath(obj, sFile)
           
            tag = BidsFileTagGetter.getEventTag();
            extension = BidsFileExtensionGetter.getEventExtension();
            
            studyName = strcat(obj.getStudyName(sFile), tag, extension);
            eventFilePath = fullfile(obj.getRawPath(sFile), studyName);
            
        end
        
        function eventMetaDataFilePath = getEventMetaDataFilePath(obj, sFile)
            
            tag = BidsFileTagGetter.getEventMetaDataTag();
            extension = BidsFileExtensionGetter.getEventMetaDataExtension();
            
            studyName = strcat(obj.getStudyName(sFile), tag, extension);
            eventMetaDataFilePath = fullfile(obj.getRawPath(sFile), studyName);
            
        end
        
        function channelFilePath = getChannelFilePath(obj, sFile)
           
            tag = BidsFileTagGetter.getChannelTag();
            extension = BidsFileExtensionGetter.getChannelExtension();
            
            studyName = strcat(obj.getStudyName(sFile), tag, extension);
            channelFilePath = fullfile(obj.getRawPath(sFile), studyName);
            
        end
        
        function electrodeFilePath = getElectrodeFilePath(obj, sFile)
           
            tag = BidsFileTagGetter.getElectrodeTag();
            extension = BidsFileExtensionGetter.getElectrodeExtension();
            
            studyName = strcat(obj.getStudyName(sFile), tag, extension);
            electrodeFilePath = fullfile(obj.getRawPath(sFile), studyName);
            
        end
        
        function coordinateFilePath = getCoordinateFilePath(obj, sFile)
           
            tag = BidsFileTagGetter.getCoordinateTag();
            extension = BidsFileExtensionGetter.getCoordinateExtension();
            
            studyName = strcat(obj.getStudyName(sFile), tag, extension);
            coordinateFilePath = fullfile(obj.getRawPath(sFile), studyName);
            
        end
                
    end
    
    methods (Access = private)
       
        function createValidFolderName(obj)
           
            while ~checkIfFolderIsValid(obj)
                if obj.isBidsFolderNumbered()
                    obj.incrementFolder();
                else
                    obj.startFolderNumberIndexing();
                end
            end
            
        end
        
        function isValid = checkIfFolderIsValid(obj)
           
            isValid = ~isfolder(fullfile(obj.FolderPath, obj.FolderName));
            
        end
       
        function setFolderNumber(obj, number)
           
            [folderNameWithoutNumber] = obj.splitFolderNameAndNumber();
            obj.FolderName = strcat(folderNameWithoutNumber, obj.SplitCharacter, num2str(number));
            
        end
        
        function [folderNameWithoutNumber, folderNumber] = splitFolderNameAndNumber(obj)
           
            indexToSplit = find(obj.FolderName == obj.SplitCharacter, 1, 'last');
                      
            if isempty(indexToSplit)
                folderNameWithoutNumber = obj.FolderName;
                folderNumber = char.empty;
            else
                folderNameWithoutNumber = obj.FolderName(1:indexToSplit-1);
                folderNumber = obj.FolderName(indexToSplit+1:end);
            end
            
        end
        
        function isNumbered = isBidsFolderNumbered(obj)
                       
            [~, charsToVerify] = obj.splitFolderNameAndNumber();
            
            if isempty(charsToVerify)
                isNumbered = false;
            else
                isNumbered = all(isstrprop(charsToVerify, 'digit'));
            end
            
        end
       
        function startFolderNumberIndexing(obj)
           
            obj.FolderName = strcat(obj.FolderName, '_0');
            
        end
        
        function incrementFolder(obj)
            
            [~, folderNumber] = obj.splitFolderNameAndNumber;
            folderNumber = str2double(folderNumber);
            obj.setFolderNumber(folderNumber+1);
            
        end

        function [subFolder, subNumber] = getSubjectFolder(obj)
           
            content = dir(fullfile(obj.FolderPath, obj.FolderName));
            
            subNumber = 0;
            for i = 1:length(content)
                if contains(content(i).name, 'sub-')
                    subNumber = subNumber + 1;
                end
            end
            
            subFolder = strcat('sub-', sprintf('%04d', subNumber));
            
        end  
        
        function rawPath = getRawPath(obj, sFile)
           
            subFolder = obj.getSubjectFolder();
            sesFolder = obj.getSessionFolder(sFile);
            bidsPath = obj.getValidBidsPath();
            
            rawPath = fullfile(bidsPath, ...
                subFolder, ...
                sesFolder, ...
                obj.getFolderType(fullfile(bidsPath, subFolder, sesFolder)));
            
        end
        
        function derivativePath = getDerivativePath(obj)
           
            derivativePath = fullfile(obj.getValidBidsPath(), 'derivatives');
            
        end
        
        function studyName = getStudyName(obj, sFile)
            
            subFolder = obj.getSubjectFolder();
            sesFolder = obj.getSessionFolder(sFile);
            runNumber = obj.getRunNumber(obj.getRawPath(sFile));
            
            studyName = strcat( subFolder, '_', ...
                                sesFolder, '_task-', ...
                                replace(sFile.Condition(5:end), '_', ''), '_', ...
                                'run-', sprintf('%02d', runNumber));
                        
        end
        
    end
    
    methods (Static, Access = private)
        
        function [sesFolder, sesDate] = getSessionFolder(sFile)
           
            sesDate = BstUtility.getDateFromBrainstormStudyMAT(sFile);
            sesDate.Format = 'yyyyMMdd';
            
            sesFolder = strcat('ses-', char(sesDate));
            
        end
        
        function runNumber = getRunNumber(folder)
           
            content = dir(folder);
            nbFiles = length(content);
            
            targetString = 'run-';
            runNumbers = zeros(1, nbFiles);
            for i = 1:nbFiles
                splitIndex = strfind(content(i).name, targetString);
                runNumbers(i) = str2double(content(i).name(splitIndex+length(targetString):splitIndex+length(targetString)+1));
            end
            
            runNumber = max(runNumbers);
            
        end 
        
        function typeFolder = getFolderType(folder)
            
            names = string({dir(folder).name});
            
            eegChar = 'eeg';
            megChar = 'meg';
            
            if any(eegChar == names)
                typeFolder = eegChar;
            elseif any(megChar == names)
                typeFolder = megChar;
            else
                typeFolder = char.empty;
            end
            
        end
     
    end
    
end