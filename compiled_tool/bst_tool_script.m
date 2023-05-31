function output_folder = bst_tool_script(bids_folder, pipeline_file)
% bst_tool_script Apply a pipeline on a BIDS dataset.
%
%   [USAGE]
%       sFilesOut = bst_tool_script(bids_folder, pipeline_file)
%   
%   [IN]
%       [string/char] bids_folder: BIDS dataset.
%       [string/char] pipeline_file: Pipeline.
%
%   [OUT]
%       [structure] output_folder: Output folder.
        
    % Check BIDS folder
    if ~endsWith(bids_folder, filesep)
        bids_folder = [bids_folder filesep];
    end
    assert(isfolder(bids_folder), ['BIDS folder does not exists: ' newline bids_folder]);
    
    % Get BIDS folder name
    split_path = strsplit(bids_folder, filesep);
    bids_folder_name = split_path{end-1};
    
    % Create output folder
    date_as_str = datestr(datetime, 'yymmdd_hhMMss');
    if isfolder('/input') && isfolder('/output')
        % Save in container
        parent_folder = '/output';
    else
        % Save on local computer
        parent_folder = strjoin(split_path(1:end-2), filesep);
    end
    output_folder = fullfile(parent_folder, [bids_folder_name '_output'], date_as_str);
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end

    % Create pipeline
    pipeline = pipeline_create(pipeline_file);
    
    % Create protocol
    protocol_name = 'EEGNet_protocol';
    protocol_path = bst_fullfile(bst_get('BrainstormDbDir'), protocol_name);
    if isfolder(protocol_path)
        rmdir(protocol_path, 's');
    end
    protocol_create(protocol_name);

    try
        % Start report
        bst_report('Start');        

        % Import BIDS dataset
        import_bids = process_create('import_bids');
        import_bids.set_option('bidsdir', bids_folder);
        sFiles =  import_bids.run();

        % Run pipeline
        sFilesOut = pipeline.run(sFiles);

        % Export to BIDS
        bids_ouput_folder = fullfile(output_folder, 'bids');
        copyfile(bids_folder, bids_ouput_folder);
        custom_export_bids(sFilesOut, bids_ouput_folder);

        % Copy brainstorm protocol folder
        disp('Copying Brainstorm database.');
        current_protocol_folder = protocol_get_path(protocol_name);
        bst_output_folder = fullfile(output_folder, 'bst_db');
        copyfile(current_protocol_folder, bst_output_folder);

        % Save and export report
        ReportFile = bst_report('Save', []);
        bst_report('Export', ReportFile, output_folder);
        
    catch ME
        % Delete protocol
        protocol_delete(protocol_name);
        rethrow(ME);      
    end
    
    % Delete protocol
    protocol_delete(protocol_name);
end