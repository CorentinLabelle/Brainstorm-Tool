classdef DatabaseSearcher
    
    methods (Static, Access = public)
        
        function sFiles = selectFiles(subjectName, condition)
            arguments
                subjectName string
                condition string
            end
            
            for i = 1:length(subjectName)
                sFiles = bst_process('CallProcess', 'process_select_files_data', [], [], ...
                    'subjectname',   subjectName{i}, ...
                    'condition',     condition{i}, ...
                    'tag',           '', ...    Select file that include the tag
                    'includebad',    0, ...     1/0
                    'includeintra',  0, ...     1/0
                    'includecommon', 0);        %1/0
            end
            
        end
        
        function sFiles = searchQuery(varargin)
           
                inputs = string(varargin);
                queryAsChar = DatabaseSearcher.buildRequestAsCharacter(inputs);
            
                sFiles = bst_process('CallProcess', 'process_select_search', [], [], ...
                    'search', queryAsChar);
                
        end
        
    end
    
    methods (Static, Access = private)
       
        function queryAsChar = buildRequestAsCharacter(inputs)
           
            nbWordsPerRequest = 4;
            nbRequest = (length(inputs)+1) / nbWordsPerRequest;
            assert(rem(nbRequest, 1) == 0);
            
            queryAsChar = '(';
            for i = 1:nbRequest
               
                startIndex = ((i-1)*nbWordsPerRequest)+1;
                searchBy = inputs{startIndex};
                [equality, isNot] = DatabaseSearcher.getEquality(inputs{startIndex+1});
                searchFor = inputs{startIndex+2};
                   
                a = [upper(isNot) '[' lower(searchBy) ' ' upper(equality) ' ' '"' lower(searchFor) '"]'];
                
                if i == nbRequest
                    queryAsChar = [queryAsChar a ')'];
                else
                    queryAsChar = [queryAsChar a ' ' inputs{startIndex+3} ' ' ];
                end
                
            end
        
        end
        
        function [equality, isNot] = getEquality(inputString)
            
            stringSplit = string(split(inputString, ' '));
            
            if length(stringSplit) == 1
                isNot = char.empty();
                equality = stringSplit{1};
            elseif length(stringSplit) == 2
                isNot = stringSplit{1};
                equality = stringSplit{2};
            end
                
            
        end
        
    end
end