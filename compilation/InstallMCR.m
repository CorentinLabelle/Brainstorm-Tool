function InstallMCR()

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
    
    instructionsToRunInCommandLine = 'No instruction';
            
    downloadRuntime = askToDownloadRuntime();
    
    if ~downloadRuntime
        return
    else
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

        disp(instructionsToRunInCommandLine);

    end
    
end

function yesOrNo = askToDownloadRuntime()

    while true
        answer = input('Do you want to download the latest MATLAB Runtime ? (y/n) ', 's');
        answer = lower(answer);

        if strcmp(answer, 'y')
            yesOrNo = true;
            break;
        elseif strcmp(answer, 'n')
            yesOrNo = false;
            break;               
        end
        
    end
        
end