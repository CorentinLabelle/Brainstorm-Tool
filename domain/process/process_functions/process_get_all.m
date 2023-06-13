% TAKEN FROM BRAINSTORM
% File: /brainstorm3/toolbox/process/panel_process_select.m
% Line: 2607

function bstFunc = process_get_all(NameValueArgs)
    arguments
        NameValueArgs.PlugIn = 0;
    end
    
    if ~brainstorm('status')
        brainstorm nogui;
    end
    
    % ===== LIST PROCESS FILES =====
    % Get the contents of sub-folder "functions"
    bstList = dir(bst_fullfile(bst_get('BrainstormHomeDir'), 'toolbox', 'process', 'functions', 'process_*.m'));
    bstFunc = {bstList.name};
    
    % Get the contents of user's custom processes ($HOME/.brainstorm/process)
    usrList = dir(bst_fullfile(bst_get('UserProcessDir'), 'process_*.m'));
    usrFunc = {usrList.name};
    % Display warning for overridden processes
    override = intersect(usrFunc, bstFunc);
    for i = 1:length(override)
        disp(['BST> ' override{i} ' overridden by user (' bst_get('UserProcessDir') ')']);
    end
    % Add user processes to list of processes
    if ~isempty(usrFunc)
        bstFunc = union(usrFunc, bstFunc);
    end
    
    % Get processes from installed plugins ($HOME/.brainstorm/plugins/*)
    plugFunc = {};
    PlugAll = bst_plugin('GetInstalled');
    for iPlug = 1:length(PlugAll)
        if ~isempty(PlugAll(iPlug).Processes)
            % Keep only the processes with function names that are not already defined in Brainstorm
            iOk = [];
            for iProc = 1:length(PlugAll(iPlug).Processes)
                [tmp, procFileName, procExt] = bst_fileparts(PlugAll(iPlug).Processes{iProc});
                if ~ismember([procFileName, procExt], bstFunc)
                    iOk = [iOk, iProc];
                else
                    % disp(['BST> Plugin ' PlugAll(iPlug).Name ': ' procFileName procExt ' already defined in Brainstorm']);
                end
            end
            % Concatenate plugin path and process function (relative to plugin path)
            procFullPath = cellfun(@(c)bst_fullfile(PlugAll(iPlug).Path, c), PlugAll(iPlug).Processes(iOk), 'UniformOutput', 0);
            plugFunc = cat(2, plugFunc, procFullPath);
        end
    end
    % Add plugin processes to list of processes
    if ~isempty(plugFunc) && NameValueArgs.PlugIn
        bstFunc = union(plugFunc, bstFunc);
    end