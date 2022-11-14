%% Save pipeline
clear
clc

%% Setup
eegPip = CreateFullEegPipeline();

disp(['Folder: ' eegPip.getFolder()]);
disp(['Name: ' eegPip.getName()]);
disp(['Extension: ' eegPip.getExtension()]);

% Save pipeline with pipeline's extension
eegPip.save();

%% Save pipeline to .json
%eegPip.save2json();

%% Save pipeline to .mat
eegPip.save2mat();
    
%% End
endMessage;