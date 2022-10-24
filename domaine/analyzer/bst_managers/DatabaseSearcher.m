classdef DatabaseSearcher
    
    methods (Static, Access = public)
        
        function sFiles = searchQuery(varargin)           
                inputs = string(varargin);
                queryAsChar = DatabaseSearcher.buildRequestAsCharacter(inputs);
            
                sFiles = bst_process('CallProcess', 'process_select_search', [], [], ...
                    'search', ['(' queryAsChar ')']);
                
                if isempty(sFiles)
                    warning('The search query has no result (output is empty)'); 
                end
        end
        
        function sFiles = getAllsFiles()
            sFiles = DatabaseSearcher.searchQuery('path', 'contains', '.');
        end
        
        function getInstruction()
            clc
            disp('<strong>Instruction to build a request:</strong>');
            disp('<strong>1. SearchBy:</strong>     (NAME, fileTYPE, filePATH, PARENTname)');
            disp('<strong>2. Equality:</strong>     (CONTAINS, NOT CONTAINS, EQUALS, NOT EQUALS)');
            disp('<strong>3. SearchFor:</strong>    (the characters you are looking for)');
            disp('<strong>4. And/Or:</strong>       (AND, OR)');
            disp('<strong>5. FunctionToCall:</strong> DatabaseSearcher.searchQuery(arguments)');
        end
        
    end
    
    methods (Static, Access = private)
       
        function queryAsChar = buildRequestAsCharacter(inputs)           
            nbWordsPerRequest = 4;
            nbRequest = (length(inputs)+1) / nbWordsPerRequest;
            assert(floor(nbRequest) == nbRequest, 'The number of argument is invalid.');
            
            queryAsChar = '(';
            for i = 1:nbRequest
               
                startIndex = ((i-1)*nbWordsPerRequest)+1;
                searchBy = inputs{startIndex};
                [equality, isNot] = DatabaseSearcher.getEquality(inputs{startIndex+1});
                searchFor = inputs{startIndex+2};
                   
                queryAsChar = [queryAsChar upper(isNot) '[' lower(searchBy) ' ' upper(equality) ' "' searchFor '"]'];
                if i ~= nbRequest
                    queryAsChar = [queryAsChar ' ' upper(inputs{startIndex+3}) ' ' ];
                end                
            end
            queryAsChar = [queryAsChar ')'];       
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