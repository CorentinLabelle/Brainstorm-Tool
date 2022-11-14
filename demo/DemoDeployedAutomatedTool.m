%% Run deployed automated tool
clear
clc

%% Setup
CreateAnalysisFile;

%% Reading and running
pathToAnalysisFile = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/demo/analysis_file/analysis_file_demo.json';
[baseDirectory, instruction] = RunDeployedAutomatedTool(pathToAnalysisFile);
disp(instruction);
system(instruction);
    
%% End
endMessage;