function installMCR()
    clear
    clc

    instructions = getInstructionToInstallMCR();
    
    disp('<strong>Instructions to install Matlab Compiler Runtime:</strong>');
    disp('1. Open command window');
    disp('2. Enter: ''su philippealbouy''');
    disp('3. Enter the password');
    disp('4. Copy and run the following line in the command window:');
    fprintf('\n');
    disp(instructions);
    fprintf('\n');

end

function instructionsToRunInCommandLine = getInstructionToInstallMCR()
    clear
    clc

    % Download Matlab Runtime Compiler
    msg = msgbox('Downloading latest Matlab Runtime Compiler...', 'Downloading...');
    compiler.runtime.download;
    close(msg);

    % Unzip Matlab Runtime Compiler folder
    installerZipFolder = mcrinstaller;
    [installerZipFolderDirectory, installerZipFolderName] = fileparts(installerZipFolder);

    installerFolder = fullfile(installerZipFolderDirectory, installerZipFolderName);
    if ~isfolder(installerFolder)
        msg = msgbox('Unzipping Matlab Runtime Compiler folder', 'Unzipping...');
        unzip(installerZipFolder, installerZipFolderName);
        close(msg);
    end

    % Run Matlab Runtime Installer
    %runtimeInstallationDir = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/MATLAB/MATLAB_Runtime/';
    runtimeInstallationDir = uigetdir(matlabroot, 'Select folder to save Matlab Compiler Runtime');
    if isequal(runtimeInstallationDir, 0)
        return
    end
    
    if isunix
        command = './install';
    elseif ismac
        command = './install';
    elseif ispc
        command = 'setup';
    end

    instructionsToRunInCommandLine = [...
        'cd ' installerFolder '; ' ...
        command ' -mode silent -agreeToLicense yes -destinationFolder ' runtimeInstallationDir];

end