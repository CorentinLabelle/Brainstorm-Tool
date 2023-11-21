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
        
    disp("Brainstorm Wrapper Version: 11/21/2023");
    
    analysis_start = tic;
    gui_brainstorm('EmptyTempFolder');
    
    % Convert paths to absolute paths
    bids_folder = get_full_path(bids_folder);
    pipeline_file = get_full_path(pipeline_file);

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
%     if isfolder('/input') && isfolder('/output')
%         % Save in container
%         parent_folder = '/output';
%     else
%         % Save on local computer
%         parent_folder = strjoin(split_path(1:end-2), filesep);
%     end
    parent_folder = pwd;
    output_folder = fullfile(parent_folder, [bids_folder_name '_output'], date_as_str);
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end
    
    % Start report
    bst_report('Start');
    
    % Create protocol
    protocol_name = 'EEGNet_protocol';
    protocol_path = bst_fullfile(bst_get('BrainstormDbDir'), protocol_name);
    if isfolder(protocol_path)
        rmdir(protocol_path, 's');
    end
    protocol_create(protocol_name);

    try        

        % Import BIDS dataset
        import_bids = process_create('import_bids');
        import_bids.set_option('bidsdir', bids_folder);
        sFiles =  import_bids.run();

        [~, ~, extension] = fileparts(pipeline_file);    
        switch extension
            
            case '.json'
                disp("Reading JSON pipeline...");
                pipeline = pipeline_create(pipeline_file);
                sFilesOut = pipeline.run(sFiles, false);
                
            case '.mat'
                disp("Reading MAT pipeline...");
                sProcesses = load(pipeline_file);
                if isfield(sProcesses, 'Processes')
                    sProcesses = sProcesses.Processes;
                end
                if isempty(sProcesses)
                    warning(['Pipeline is empty: ' char(pipeline_file)]);
                    return
                end
                sFilesOut = bst_process('Run', sProcesses, sFiles, [], 0);
                
            otherwise
                error(['Invalid extension in pipeline path: ' char(extension)]);
        end

        % Export to BIDS
        bids_ouput_folder = fullfile(output_folder, 'bids');
        copyfile(bids_folder, bids_ouput_folder);
        bst_tool_export_to_bids(sFilesOut, bids_ouput_folder);
        
        % Save and export report
        ReportFile = bst_report('Save', sFilesOut);
        bst_report('Export', ReportFile, output_folder);

        % Copy brainstorm protocol folder
        disp('Copying Brainstorm database.');
        current_protocol_folder = protocol_get_path(protocol_name);
        bst_output_folder = fullfile(output_folder, 'bst_db');
        copyfile(current_protocol_folder, bst_output_folder);

        
    catch ME
        % Delete protocol
        protocol_delete(protocol_name);
        rethrow(ME);
    end
    
    % Delete protocol
    protocol_delete(protocol_name);
    
    disp(['The whole analysis took ' num2str(toc(analysis_start)) ' seconds.']);    
end