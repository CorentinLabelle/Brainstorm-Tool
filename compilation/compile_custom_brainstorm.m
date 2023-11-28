function compile_custom_brainstorm(with_plug_ins)
    arguments
        with_plug_ins = 0;
    end
    clc
    
    if ~with_plug_ins
        warning('Compiling Brainstorm WITHOUT plugins');
    end
    
    if ~brainstorm('status')
        brainstorm nogui
    end
    if ~is_java_home_set()
        set_java_home_to_point_to_open_JDK();
    end    
    if ~is_matlab_mcc_on_system_path()
        add_matlab_mcc_to_system_path();
    end
    folders_to_compile = get_folders_to_compile();
    destination_folder = fullfile(bst_get('BrainstormHomeDir'), "toolbox", "bst_tool_code");
    copyfile(folders_to_compile, destination_folder);
    if with_plug_ins
        compile_brainstorm();
    else
        compile_brainstorm_no_plugs();
    end
    % Remove custom folder from bst toolbox
    rmpath(genpath(destination_folder))
    rmdir(destination_folder, 's');    
    % Get new JAR file
    new_jar_file = get_new_jar_file();
    disp(['New JAR file:' newline new_jar_file]);
end

function set_java_home_to_point_to_open_JDK()
    java_home = uigetdir('', 'Select OpenJDK folder (jdk***)');
    setenv('JAVA_HOME', java_home);            
end

function isSet = is_java_home_set()
    java_home = getenv('JAVA_HOME');
    isSet = ~isempty(java_home) && isfolder(java_home);
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

function compile_brainstorm_no_plugs()            
    brainstorm compile noplugs;            
end

function compile_brainstorm()            
    brainstorm compile;            
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

function bst_tool_bin_folder = get_bst_bin_folder()
    bst_tool_bin_folder = fullfile(get_brainstorm_tool_dir(), 'compiled_tool', 'bin');
end

function add_matlab_mcc_to_system_path()
    mcc_folder = fullfile(matlabroot, 'bin');
    setenv('PATH', [getenv('PATH') ':' mcc_folder]);
end