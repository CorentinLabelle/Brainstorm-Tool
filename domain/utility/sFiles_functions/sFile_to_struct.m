function sFiles = sFile_to_struct(study_link)
    arguments
        study_link string
    end            
    if isempty(study_link)
        sFiles = [];
        return
    end
    for iLink = 1:length(study_link)
        link = study_link{iLink};
        link_parts = string(strsplit(link, filesep));
        link = fullfile(link_parts{end-2:end});
        sFiles(iLink) = database_searcher_search_query("path", "equals", link);
    end            
end