function compile_custom_brainstorm()
    clc
    
    with_plug_ins = ask_for_plug_ins();
    if ~with_plug_ins
        warning('Compiling Brainstorm WITHOUT plugins');
    end
    
    if ~brainstorm('status')
        brainstorm nogui
    end
    
    % Add EEGLAB path
    eeglab_path = uigetdir('', 'Select EEGLAB folder');
    addpath(eeglab_path);
    
    if ~is_java_home_set()        
        % Set JAVA_HOME to point to open JDK
        java_home = uigetdir('', 'Select OpenJDK folder (jdk***)');
        setenv('JAVA_HOME', java_home);        
    end    
    
    if ~is_matlab_mcc_on_system_path()        
        % Add matlab mcc to system path
        mcc_folder = fullfile(matlabroot, 'bin');
        setenv('PATH', [getenv('PATH') ':' mcc_folder]);
    end
    
    folders_to_compile = get_folders_to_compile();
    destination_folder = fullfile(bst_get('BrainstormHomeDir'), "toolbox", "bst_tool_code");
    copyfile(folders_to_compile, fullfile(destination_folder, 'bst_tool_code'));
    copyfile('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/eeglab/functions/', fullfile(destination_folder, 'eeglab_functions'));
    copyfile('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/eeglab/plugins/ICLabel/', fullfile(destination_folder, 'eeglab_iclabel'));
    copyfile('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/eeglab/plugins/firfilt/', fullfile(destination_folder, 'eeglab_firfilt'));
    
    if with_plug_ins
        brainstorm compile;
    else
        brainstorm compile noplugs;
    end
    
    % Remove custom folder from bst toolbox
    rmpath(genpath(destination_folder))
    rmpath(eeglab_path);
    
    rmdir(destination_folder, 's');
    
    % Get new JAR file
    new_jar_file = get_new_jar_file();
    disp(['New JAR file:' newline new_jar_file]);
    
end

function folder = get_folders_to_compile()
    path_split = strsplit(mfilename('fullpath'), filesep);
    src_folder = strjoin(path_split(1:end-2), filesep);
    folder = fullfile(src_folder, 'functions');
    answer = input([...
        'The following folder will be compiled:' newline ...
        folder ...
        newline 'Do you want to continue ? (y/n): '], "s");
    
    if ~strcmpi(answer, 'y')
        error('User answered NO, code stopped');
    end
end

function with_plug_ins = ask_for_plug_ins()
    answer = input(...
        'Do you want to compile Brainstorm with the plug-ins ? (y/n): ', "s");
    
    if strcmpi(answer, 'y')
        with_plug_ins = true;
    elseif strcmpi(answer, 'n')
        with_plug_ins = false;
    else
        error(['Invalid answer: ' answer]);
    end
end

function isSet = is_java_home_set()
    java_home = getenv('JAVA_HOME');
    isSet = ~isempty(java_home) && isfolder(java_home);
end

function bool = is_matlab_mcc_on_system_path()
    bool = ~system('command -v mcc');
end

function new_jar_file = get_new_jar_file()
    bst3_path = bst_get('BrainstormHomeDir');
    new_jar_file = fullfile(bst3_path, 'bin', char(matlabRelease.Release), 'brainstorm3.jar');
    if ~isfile(new_jar_file)
        error(['New JAR file not found:' newline new_jar_file]);
    end
end
