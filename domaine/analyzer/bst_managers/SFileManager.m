classdef SFileManager
    
    methods (Static, Access = public)
        
        function isRaw = isSFileRaw(sFile)            
            studyFile = load(SFileManager.getStudyPathFromSFile(sFile));            
            isRaw = true;
            if strcmp(studyFile.F.format, 'BST-BIN')
                isRaw = false;
            end            
        end
        
%         function sFile = getRawsFile(sFile)
%             
%            isRaw = SFileManager.isSFileRaw(sFile);
%            
%            if isRaw(sFile)
%                return
%            else
%               rawCondition = sFile.Condition(1:find(sFile.Condition == '_', 1, 'first')-1);
%               selectFilesHandle = str2func([mfilename('class') '.selectFiles']);
%               sFile = selectFilesHandle(sFile.SubjectName, rawCondition);
%               
%            end
%             
%         end

        function length = getLengthOfRecording(sFile)
            studyFile = load(SFileManager.getStudyPathFromSFile(sFile));
            length = studyFile.Time(2);
        end
        
        function path = getStudyPathFromSFile(sFile)
            path = fullfile(PathsGetter.getBstDatabaseFolder(), ...
                        bst_get('ProtocolInfo').Comment, 'data', sFile.FileName);
        end
        
        function sFiles = getsFileFromMatLink(studyLink)
            arguments
                studyLink string
            end            
            if isempty(studyLink)
                sFiles = [];
                return
            end
            sFiles = cell(1, length(studyLink));
            for i = 1:length(studyLink)
                link = SFileManager.parseLink(studyLink{i});
                sFiles{i} = DatabaseSearcher.searchQuery("path", "equals", link);
            end
            sFiles = cell2mat(sFiles);
        end
        
        function isLink = isStudyLink(sFile)
            if isstruct(sFile)
                isLink = false;
                return
            end            
            if isa(string(sFile), 'string')
                isLink = true;
                return
            end            
        end
        
        function brainstormStudyPath = getBrainstormStudyPathFromSFile(sFile)            
            brainstormStudyPath = fullfile(PathsGetter.getBstDatabaseFolder(), ...
                bst_get('ProtocolInfo').Comment, 'data', ...
                sFile.SubjectName, sFile.Condition, 'brainstormstudy.mat');            
        end
        
        function sensorType = getSensorTypeFromsFile(sFile)
            if isempty(sFile)
                sensorType = SensorType.empty;
                return
            end
            channelFilePaths = ChannelManager.getChannelFilePath(sFile);            
            sensorType = cell(1, length(sFile));
            for i = 1:length(channelFilePaths)
                sensorType{i} = SFileManager.getSensorTypeFromChannelFile(channelFilePaths{i});                
            end
            
            sensorType = unique(string(sensorType));
            assert(isscalar(sensorType));
            sensorType = SensorType.fromString(sensorType);
        end
        
    end
    
    methods (Static, Access = private)
       
        function sensorType = getSensorTypeFromChannelFile(channelFilePath)
            channelFile = load(channelFilePath);
            isEEG = any(strcmpi({channelFile.Channel.Type}, "eeg"));
            isMEG = any(strcmpi({channelFile.Channel.Type}, "meg"));
            assert(isEEG || isMEG);
            if isEEG
                sensorType = SensorType.EEG;
            elseif isMEG
                sensorType = SensorType.MEG;
            else
                error('Cannot find channel type');
            end
        end
        
        function link = parseLink(link)
            linksParts = string(strsplit(link, filesep));
            link = fullfile(linksParts{end-2:end});
        end
        
    end
    
end