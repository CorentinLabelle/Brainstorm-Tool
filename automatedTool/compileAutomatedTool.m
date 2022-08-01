clear
clc

msg = msgbox('Compiling...', 'Compiling...');

fileToCompile = ['runDeployedAutomatedTool.m' ' ' '../PathsGetter.m'];
outputFolder = fullfile(pwd, 'output');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

instructionToExecute = ['mcc -m ' fileToCompile ' -d ' outputFolder];

eval(instructionToExecute);

close(msg);