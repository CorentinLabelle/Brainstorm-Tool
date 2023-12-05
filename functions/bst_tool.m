function output_folder = bst_tool(bids_directory, pipeline_file)
% bst_tool_script Apply a pipeline to a BIDS dataset.
%   
%   [IN]
%       [char] bids_folder: Path to a BIDS dataset.
%       [char] pipeline_file: Path to a pipeline.
%
%   [OUT]
%       [char] output_folder: Path to the output folder.
    
    analysis_start = tic;
    
    disp('Deleting temporary Brainstorm files...');
    gui_brainstorm('EmptyTempFolder');
    
    % Convert paths to absolute paths
    bids_directory = get_full_path(bids_directory);
    pipeline_file = get_full_path(pipeline_file);
    
    % Check BIDS folder
    if ~endsWith(bids_directory, filesep)
        bids_directory = [bids_directory filesep];
    end
    if ~isfolder(bids_directory)
        error(['BIDS folder does not exists: ' newline bids_directory]);
    end
    
    % Get BIDS folder name
    split_path = strsplit(bids_directory, filesep);
    bids_folder_name = split_path{end-1};
    
    % Create output folder
    disp('Creating output folder...');
    date_as_str = datestr(datetime, 'yymmdd_hhMMss');
    parent_folder = pwd;
    output_folder = fullfile(parent_folder, [bids_folder_name '_output'], date_as_str);
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end
    
    % Load pipeline
    disp('Loading pipeline...');
    pipeline = load_pipeline(pipeline_file);
    if isempty(pipeline)
        warning(['Pipeline is empty: ' char(pipeline_path)]);
        return
    end
    
    % Start report
    bst_report('Start');
    
    % Create protocol
    disp('Creating protocol...');
    protocol_name = 'EEGNet_protocol';
    protocol_path = bst_fullfile(bst_get('BrainstormDbDir'), protocol_name);
    if isfolder(protocol_path)
        gui_brainstorm('DeleteProtocol', protocol_name);
    end
    gui_brainstorm( 'CreateProtocol', protocol_name, 0, 0);

    try        

        % Insert 'process_import_bids' in pipeline
        import_bids_process = import_bids(bids_directory);
        pipeline = [import_bids_process pipeline];
        
        % Execute pipeline
        sFilesIn = [];
        sFilesOut = bst_process('Run_EEGNET', pipeline, sFilesIn, [], 0);

        % Copy original BIDS dataset to output folder
        disp('Copying original BIDS dataset...');
        bids_output_folder = fullfile(output_folder, 'bids');
        copyfile(bids_directory, bids_output_folder);
        
        % Export outputs
        disp('Exporting files...');
        bst_tool_folder = fullfile(bids_output_folder, 'derivatives', 'bst_tool');
        pipeline_output_folder = fullfile(bst_tool_folder, 'pipeline_output');
        export_output(sFilesOut, pipeline_output_folder);
        
        % Save report to MAT
        disp('Saving report...');
        report_file_path = fullfile(output_folder, ['report_' date_as_str]);
        ReportFile = bst_report('Save', sFilesOut, report_file_path);
        
        % Export report to HTML
        disp('Exporting report to HTML...');
        bst_report('Export', ReportFile, output_folder);
        
        % Copy pipeline
        disp('Copying pipeline...');
        copyfile(pipeline_file, bst_tool_folder);

        % Copy brainstorm protocol folder
        disp('Copying Brainstorm database...');
        current_protocol_info = bst_get('ProtocolInfo');
        current_protocol_folder = bst_fullfile(bst_get('BrainstormDbDir'), current_protocol_info.Comment);
        bst_output_folder = fullfile(output_folder, 'bst_db');
        copyfile(current_protocol_folder, bst_output_folder);
        
    catch ME
        
        % Delete protocol
        gui_brainstorm('DeleteProtocol', protocol_name);
        rethrow(ME);
        
    end
    
    % Delete protocol
    gui_brainstorm('DeleteProtocol', protocol_name);
    
    disp(['The whole analysis was executed in ' num2str(toc(analysis_start)) ' seconds.']);
    disp(['Output folder: ' output_folder]);
end