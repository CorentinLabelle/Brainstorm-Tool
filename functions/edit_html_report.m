function edit_html_report(html_path)
% This function edits all the href from the HTML.
% By default, all the href starts with 'file://...'.
% These links are edited to start with 'bst_db/data/' instead, 
% so it can be displayed in CBRAIN.

% Ex.:
% href="file://sub-0001/@rawsub-0001..." --> href="bst_db/data/sub-0001/@rawsub-0001..."

    html_code = fileread(html_path);
    html_code_edited = strrep(html_code, 'href="file://', 'href="bst_db/data/');
    
    file_id = fopen(html_path, 'w');
    fwrite(file_id, html_code_edited);
    fclose(file_id);
end

