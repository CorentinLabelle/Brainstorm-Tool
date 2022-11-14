%% Load pipeline
clear
clc

%% Setup
SavePipeline();

%% Load Pipeline
pathToPipeline = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/demo/pipeline/eegPipeline.json';
pip = Pipeline(pathToPipeline);
    
%% End
endMessage;