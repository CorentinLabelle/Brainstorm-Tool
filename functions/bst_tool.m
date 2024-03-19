function output_folder = bst_tool(bids_directory, pipeline_file, additionnal_files)
% bst_tool_script Apply a pipeline to a BIDS dataset.
%   
%   [IN]
%       [char] bids_folder: Path to a BIDS dataset.
%       [char] pipeline_file: Path to a pipeline.
%       [char] additional_files: Path to a folder.
%
%   [OUT]
%       [char] output_folder: Path to the output folder.
%
% Output structure:
%   │─── bids
%   │   │─── derivatives
%   │   │   │─── bst_tool
%   │   │   │   │─── pipeline_output
%   │   │   │   │   │─── sub-0001
%   │   │   │   │   │   │─── ...
%   │   │   │   │   │─── sub-0002
%   │   │   │   │   │   │─── ...
%   │   │   │   │   │─── ...
%   │   │   │   │─── <copy_of_pipeline>.<ext>
%   │   │   │
%   │   │   │─── bst_db_mapping.mat
%   │   │
%   │   │─── sub-0001
%   │   │   │─── ...
%   │   │─── sub-0002
%   │   │   │─── ...
%   │   │─── ...
%   │   │─── dataset_description.json
%   │
%   │─── bst_db
%   │   │─── anat
%   │   │─── data
%   │
%   │─── report_YYMMDD_HHmmss.html
%   │─── report_YYMMDD_HHmmss.mat

    if nargin < 3 || strcmp(additionnal_files, '-')
        additionnal_files = '';
    end
    
    protocol_name = 'EEGNet_protocol';
    gui_brainstorm('DeleteProtocol', protocol_name);

    try

        analysis_start = tic;

        disp('Deleting temporary Brainstorm files');
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

        % Load pipeline
        disp(['Loading pipeline: ' pipeline_file]);
        pipeline = load_pipeline(pipeline_file);
        if isempty(pipeline)
            warning(['Pipeline is empty: ' char(pipeline_path)]);
            return
        end
        pipeline = modify_filepaths_in_pipeline_options(pipeline, additionnal_files);
        
        % Get BIDS folder name
        split_path = strsplit(bids_directory, filesep);
        bids_folder_name = split_path{end-1};

        % Create output folder
        date_as_str = datestr(datetime, 'yymmdd_hhMMss');
        parent_folder = pwd;
        output_folder = fullfile(parent_folder, [bids_folder_name '_output'], date_as_str);
        disp(['Creating output folder: ' output_folder]);
        if ~isfolder(output_folder)
            mkdir(output_folder);
        end
        
        % Start report
        bst_report('Start');

        % Create protocol
        protocol_path = bst_fullfile(bst_get('BrainstormDbDir'), protocol_name);
        if isfolder(protocol_path)
            gui_brainstorm('DeleteProtocol', protocol_name);
        end
        disp(['Creating protocol: ' protocol_name]);
        gui_brainstorm( 'CreateProtocol', protocol_name, 0, 0);
        
        % Insert 'process_import_bids' in pipeline
        import_bids_process = import_bids(bids_directory);
        pipeline = [import_bids_process pipeline];
        
        % Execute pipeline
        disp('Executing pipeline...');
        sFilesIn = [];
        sFilesOut = bst_process('Run_EEGNET', pipeline, sFilesIn, [], 0);
        disp('Pipeline finished');

        % Copy original BIDS dataset to output folder
        disp('Copying original BIDS dataset');
        bids_output_folder = fullfile(output_folder, 'bids');
        disp([blanks(3) 'Source: ' bids_directory]);
        disp([blanks(3) 'Destination: ' bids_output_folder]);
        if ~isfolder(bids_output_folder)
            mkdir(bids_output_folder);
        end
        copyfile(bids_directory, bids_output_folder);
        
        % Export outputs
        disp(['Exporting processed files (' num2str(length(sFilesOut)) ' files)']);
        bst_tool_folder = fullfile(bids_output_folder, 'derivatives', 'bst_tool');
        pipeline_output_folder = fullfile(bst_tool_folder, 'pipeline_output');
        disp([blanks(3) 'Destination: ' pipeline_output_folder]);
        if ~isfolder(pipeline_output_folder)
            mkdir(pipeline_output_folder);
        end
        export_output(sFilesOut, pipeline_output_folder);
        
        % Save report to MAT
        report_file_path = fullfile(output_folder, ['report_' date_as_str]);
        ReportFile = bst_report('Save', sFilesOut, report_file_path);
        disp(['Saving report: ' ReportFile]);
        
        % Export report to HTML
        disp('Exporting report to HTML');
        disp([blanks(3) 'Source: ' ReportFile]);
        disp([blanks(3) 'Destination: ' output_folder]);
        html_report_path = bst_report('Export', ReportFile, output_folder);
        
        % Edit HTML report
        edit_html_report(html_report_path);
        
        % Copy pipeline
        disp('Copying pipeline');
        disp([blanks(3) 'Source: ' pipeline_file]);
        disp([blanks(3) 'Destination: ' bst_tool_folder]);
        copyfile(pipeline_file, bst_tool_folder);

        % Copy brainstorm protocol folder
        disp('Copying Brainstorm database');
        current_protocol_info = bst_get('ProtocolInfo');
        current_protocol_folder = bst_fullfile(bst_get('BrainstormDbDir'), current_protocol_info.Comment);
        bst_output_folder = fullfile(output_folder, 'bst_db');
        disp([blanks(3) 'Source: ' current_protocol_folder]);
        disp([blanks(3) 'Destination: ' bst_output_folder]);
        if ~isfolder(bst_output_folder)
            mkdir(bst_output_folder);
        end
        copyfile(current_protocol_folder, bst_output_folder);
        
    catch ME
        
        % Delete protocol
        gui_brainstorm('DeleteProtocol', protocol_name);
        
        % Display error message
        disp(newline);
        disp('*** Error ***');
        disp(getReport(ME));
        disp(newline);
        disp('*** Error ***');
        
        exit(1);
    end
    
    % Delete protocol
    gui_brainstorm('DeleteProtocol', protocol_name);
    
    disp(['Output folder: ' output_folder]);
    disp([newline 'The whole analysis was executed in ' num2str(toc(analysis_start)) ' seconds.']);
end