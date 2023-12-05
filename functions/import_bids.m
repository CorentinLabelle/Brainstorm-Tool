function import_bids_process = import_bids(bids_directory)
    import_bids_process = load_sProcess('process_import_bids');
    import_bids_process.options.bidsdir = ...
        option_set_value(import_bids_process.options.bidsdir, {bids_directory, 'BIDS'});
end