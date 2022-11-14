%% Creating an analysis file
clear
clc

% Setup path
filename = 'analysis_file_demo.json';
pathToAnalysisFile = fullfile(fileparts(mfilename('fullpath')), 'analysis_file', filename);

% Get pipeline
pip = CreateFullEegPipeline();
pip.save2json();
protocol = 'AutomatedToolProtocol';
sFile = [];

% Create Analysis file
afc = AnalysisFileCreator();
afc.setPipeline(pip);
afc.setProtocol(protocol);
afc.setSFile(sFile);

afc.createAnalysisFile(pathToAnalysisFile);

%% End
disp(['Done with script ' mfilename]);