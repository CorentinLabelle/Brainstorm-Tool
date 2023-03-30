function sProcess = process_load_sProcess(process_name)
    process_name = process_format_name(process_name);
    sProcess = panel_process_select('LoadExternalProcess', process_name);
    if isempty(sProcess)
        error(['Process not found: ' process_name]);
    end
end 