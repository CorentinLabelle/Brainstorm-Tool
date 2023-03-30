function output_folder = bst_tool_script(bids_folder, pipeline_file)
% bst_tool_script Apply a pipeline on a BIDS dataset.
%
%   [USAGE]
%       sFilesOut = bst_tool_script(bids_folder, pipeline_file)
%   
%   [IN]
%       [string/char] bids_folder: Path to a BIDS dataset.
%       [string/char] pipeline_file: Path to a pipeline.
%
%   [OUT]
%       [structure] output_folder: Path to the output folder.
        
    % Check BIDS folder
    if ~endsWith(bids_folder, filesep)
        bids_folder = [bids_folder filesep];
    end
    assert(isfolder(bids_folder), ['BIDS folder does not exists: ' newline bids_folder]);
    
    % Create output folder
    output_folder = fullfile(strcat(fileparts(bids_folder), '_output'), datestr(datetime, 'yymmdd_hhMMss'));
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
        custom_export_bids(sFilesOut, bids_ouput_folder);

        % Copy brainstorm protocol folder
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