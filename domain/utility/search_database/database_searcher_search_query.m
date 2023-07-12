function sFiles = database_searcher_search_query(varargin)           
    inputs = string(varargin);
    queryAsChar = build_request_as_character(inputs);

    sFiles = bst_process('CallProcess', 'process_select_search', [], [], ...
        'search', ['(' queryAsChar ')']);

    if isempty(sFiles)
        warning('The search query has no result (output is empty)'); 
    end
    
end

function queryAsChar = build_request_as_character(inputs)           
    nbWordsPerRequest = 4;
    nbRequest = (length(inputs)+1) / nbWordsPerRequest;
    assert(floor(nbRequest) == nbRequest, 'The number of argument is invalid.');

    queryAsChar = '(';
    for i = 1:nbRequest

        startIndex = ((i-1)*nbWordsPerRequest)+1;
        searchBy = inputs{startIndex};
        [equality, isNot] = get_equality(inputs{startIndex+1});
        searchFor = inputs{startIndex+2};

        queryAsChar = [queryAsChar upper(isNot) '[' lower(searchBy) ' ' upper(equality) ' "' searchFor '"]'];
        if i ~= nbRequest
            queryAsChar = [queryAsChar ' ' upper(inputs{startIndex+3}) ' ' ];
        end                
    end
    queryAsChar = [queryAsChar ')'];       
end

function [equality, isNot] = get_equality(inputString)            
    stringSplit = string(split(inputString, ' '));            
    if length(stringSplit) == 1
        isNot = char.empty();
        equality = stringSplit{1};
    elseif length(stringSplit) == 2
        isNot = stringSplit{1};
        equality = stringSplit{2};
    end
end
        