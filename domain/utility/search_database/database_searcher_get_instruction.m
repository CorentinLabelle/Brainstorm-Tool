function database_searcher_get_instruction()
    clc
    disp('<strong>Instruction to build a request:</strong>');
    disp('<strong>1. SearchBy:</strong>     (NAME, fileTYPE, filePATH, PARENTname)');
    disp('<strong>2. Equality:</strong>     (CONTAINS, NOT CONTAINS, EQUALS, NOT EQUALS)');
    disp('<strong>3. SearchFor:</strong>    (the characters you are looking for)');
    disp('<strong>4. And/Or:</strong>       (AND, OR)');
    disp('<strong>5. FunctionToCall:</strong> DatabaseSearcher.searchQuery(arguments)');
end