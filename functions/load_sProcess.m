function sProcess = load_sProcess(process_name)
    sProcess = panel_process_select('LoadExternalProcess', process_name);
    if isempty(sProcess)
        error(['Process not found: ' process_name]);
    end
end