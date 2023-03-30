function sFilesOut = export_data_custom(sFilesIn, folder, extension)    
    disp('Exporting Files ...');
    data = {sFilesIn.FileName};
    channel_mat = [];    
    [~, dataBase] = bst_fileparts(data{1});
    export_file = bst_fullfile(folder, [dataBase, extension]);
    export_file = strrep(export_file, '_data', '');
    export_file = strrep(export_file, 'data_', '');
    export_file = strrep(export_file, '0raw_', '');    
    [~, sFilesOut] = export_data(data, channel_mat, export_file);    
end