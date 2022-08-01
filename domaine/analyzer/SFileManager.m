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
        
        function path = getStudyPathFromSFile(sFile)
           
            path = fullfile(GetDatabasePath(), ...
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
            
            for i = 1:length(studyLink)
                sFiles(i) = DatabaseSearcher.searchQuery("path", "equals", studyLink{i});
%                 sFile(i) = bst_process('CallProcess', 'process_select_search', [], [], ...
%                     'search', ['([path EQUALS "'  '"])']);
            end
            
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
        
        function BrainstormStudyPath = getBrainstormStudyPathFromSFile(sFile)
            
            BrainstormStudyPath = fullfile(GetDatabasePath(), ...
                bst_get('ProtocolInfo').Comment, 'data', ...
                sFile.SubjectName, sFile.Condition, 'brainstormstudy.mat');
            
        end
        
        function channelType = getDataTypeFromsFile(sFile)
           
            if isempty(sFile)
                channelType = string.empty();
                return
            end
            
            channelFilePaths = GetChannelFilePath(sFile);
            
            channelType = strings(1, length(sFile));
            for i = 1:length(channelFilePaths)
                channelFile = load(channelFilePaths{i});
                isEEG = any(strcmpi({channelFile.Channel.Type}, "eeg"));
                isMEG = any(strcmpi({channelFile.Channel.Type}, "meg"));
                assert(isEEG || isMEG);
                
                if isEEG
                    channelType(i) = "eeg";
                elseif isMEG
                    channelType(i) = "meg";
                else
                    error('Cannot find channel type');
                end
            end
            
            channelType = string(unique(channelType));
            assert(length(channelType) == 1);
            
        end
        
    end
    
end