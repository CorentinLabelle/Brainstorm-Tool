function create_sidecars(isEeg, prefixTask, taskName, rest, megFolder, sInput, OPTIONS, outputFolder, rawName)
    addpath(genpath('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/export_to_bids/code/'));
    filename = [prefixTask taskName rest];
    
    original_coordinate_system = 'scs';
    bids_coordinate_system = 'captrak';
    
    bids_channel_file = convert_channel_file_to_different_coordinate_system(sInput, original_coordinate_system, bids_coordinate_system);
    
    derivative_folder = bst_fullfile(outputFolder, 'derivatives');
    if ~isfolder(derivative_folder)
        mkdir(derivative_folder);
    end
    
    % Create events.json (CERVO)
    event_json_path = bst_fullfile(megFolder, [filename '_events.json']);
    event_descriptor = char.empty();
    if isfield(OPTIONS, 'EventDescriptor')
        event_descriptor = OPTIONS.EventDescriptor;
    end
    create_event_json_file(sInput, event_json_path, event_descriptor);  

    % Create coordsystem.json (CERVO)
    coord_json_path = bst_fullfile(megFolder, [filename '_coordsystem.json']);
    create_coordinate_system_json_file(sInput, coord_json_path, bids_coordinate_system, isEeg);

    % Create provenance.json (CERVO)
    if isfield(OPTIONS, 'WithProvenanceFile') && OPTIONS.WithProvenanceFile
        provenance_json_path = bst_fullfile(derivative_folder, [rawName '_provenance.json']);
        create_provenance_file(sInput, provenance_json_path);
    end

    % Create event.tsv (CERVO)
    event_tsv_path = bst_fullfile(megFolder, [filename '_events.tsv']);
    create_event_tsv_file(sInput, event_tsv_path);

    % Create electrodes.tsv (CERVO)
    if isEeg
        electrode_tsv_path = bst_fullfile(megFolder, [filename '_electrodes.tsv']);
        create_electrode_tsv_file(bids_channel_file, electrode_tsv_path);
    end

    % Create channels.tsv (CERVO)   
    channel_tsv_path = bst_fullfile(megFolder, [filename '_channels.tsv']);
    create_channel_tsv_file(sInput, channel_tsv_path, isEeg);
end