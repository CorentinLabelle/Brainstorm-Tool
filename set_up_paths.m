function set_up_paths()
    current_file_path = mfilename('fullpath');
    current_file_dir = fileparts(current_file_path);
    addpath(genpath(current_file_dir));
    add_brainstorm3_path();
end

function add_brainstorm3_path()
    if is_bst3_folder_in_matlab_path()
        disp('Brainstorm3 folder already added.');
        return
    end            
    bst3_folder = uigetdir(pwd, 'Select brainstorm3 folder');
    if isequal(bst3_folder, 0)
        return
    end
    [~, folderName] = fileparts(bst3_folder);
    expected_folder_name = 'brainstorm3';
    if ~strcmp(folderName, expected_folder_name)
        error(['Wrong folder (' folderName '). Should be ' expected_folder_name '.']);
    end
    if ~isdeployed()
        addpath(bst3_folder);
        disp('Brainstorm3 folder added.');
        brainstorm setpath
    end
end

function bool = is_bst3_folder_in_matlab_path()
    [~, folders_in_search_paths] = fileparts(regexp(path, pathsep, 'Split'));
    bool = any(strcmp('brainstorm3', folders_in_search_paths)); 
end