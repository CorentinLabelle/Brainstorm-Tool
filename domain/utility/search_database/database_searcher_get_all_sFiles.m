function sFiles = database_searcher_get_all_sFiles()
    sFiles = database_searcher_search_query('path', 'contains', '.');
end