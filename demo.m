%% Add Paths
clear
clc

cd('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool');

paths = ["domaine", ...
        "interface", ...
        "utility", ...
        "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/pipelines"
        ];

for i = 1:length(paths)
    addpath(genpath(paths(i)));
end

%% Start App
tool = analysisTool(1,0);


%% AVAILABLE PROCESSES
clc
Process.printAvailableProcesses;

%% CREATE EMPTY EEG PROCESS
clc

eegEmptyScalar = Process();
eegEmptyArray(1:5) = Process();
eegEmptyMatrix(1:5, 1:8) = Process();


%% CREATE EEG PROCESS
clc

allProcesses = Process.getAllProcesses();
genProcesses = string(fieldnames(allProcesses.GeneralProcess)');
specProcesses = string(fieldnames(allProcesses.SpecificProcess)');
eegProcesses = string(fieldnames(allProcesses.EEG_Process)');
megProcesses = string(fieldnames(allProcesses.MEG_Process)');

genArray = Process.create(genProcesses);
specArray = Process.create(specProcesses);
eegArray = Process.create(eegProcesses);
megArray = Process.create(megProcesses);
                
rrf = Process.create('Review Raw Files');
nf = Process.create('Notch Filter');
bpf = Process.create('Band-Pass Filter');
psdp = Process.create('Power Spectrum Density');
ica = Process.create('ICA');
etb = Process.create('Export To BIDS');
aep = Process.create('Add EEG Position');
rr = Process.create('Refine Registration');
peos = Process.create('Project Electrode On Scalp');
ar = Process.create('Average Reference');


%% ADD PARAMETERS WITH VALUES
clc

nf.setParameter('Frequence', 60);
bpf.setParameter('Frequence', [10, 90]);
aep.setParameter('Cap', 'Colin', 'FileType', 'Import Default');

nf.print;
bpf.print;
aep.print;

%% ADD PARAMETERS WITH STRUCTURE
clc

psdParam = struct();
psdParam.WindowLength = 10;
psdp.setParameterWithStructure(psdParam);

icaParam = struct();
icaParam.NumberOfComponents = 32;
ica.setParameterWithStructure(icaParam);

bidsParam = struct();
bidsParam.Folder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/';
bidsParam.DataFileFormat = 'edf';
etb.setParameterWithStructure(bidsParam);

psdp.print;
ica.print;
etb.print;

%% SET DOCUMENTATION
clc

doc = '60Hz power line frequency';
nf.setDocumentation(doc);
nf.printDocumentation;

%% VIEW WEB DOCUMENTATION
clc

%nf.openWebDocumentation();

%% IS PROCESS IN
clc

inSpec = rrf.isIn(specArray);
inGen = rrf.isIn(genArray);
inEeg = rrf.isIn(eegArray);
inMeg = rrf.isIn(megArray);
disp(inSpec);
disp(inGen);
disp(inEeg);
disp(inMeg);

%% RUN PROCESS
clc

% Select data in interface
data = tool.selected_Studies();
%nf = EEG_Process(nf);
sFileOut = nf.run(data);


%% VIEW PROCESS CLASS DOCUMENTATION
clc
help Process

%% CREATE PIPELINE
clc
pip = Pipeline();

pip.setName('pip_demo');
pip.setFolder('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/pipelines');

pip.print;

%% ADD PROCESS
clc
a=[aep, rrf, nf, bpf];
pip.addProcess(a);
pip.print;

%% ADD PROCESS WITH INDEX
clc

pip.addProcess(ica, 2);
pip.print;

%% Search Process

index = pip.getProcessIndexWithName(["Review Raw Files", "ICA"]);

%isIn = pip.isProcessesInPipeline(pip.Processes(index));

%% EXTRACT PROCESS
clc

extracted_pr = pip.Processes(3);
extracted_pr.print;

%% MOVE PROCESS
clc

pip.moveProcess(1, 3);
pip.printProcess;

%% SWAP PROCESS
clc

pip.swapProcess(1, 3);
pip.printProcess;

%% DELETE PROCESS
clc

pip.deleteProcess(3);
pip.deleteProcess(1);
pip.printProcess;

%% change directory
cd(pip.Folder);

%% SAVE PIPELINE
clc

pip.addExtension('.mat');
pip.addExtension('.json');
pip.save();




%% LOAD PIPELINE
clc

pipLoadMat = Pipeline(fullfile(pip.Folder, strcat(pip.Name, '.mat')));
pipLoadJson = Pipeline(fullfile(pip.Folder, strcat(pip.Name, '.json')));

%% VIEW PIPELINE CLASS DOCUMENTATION
clc
help Pipeline;

%% RUN PIPELINE

% waitfor(msgbox('Select Dataset in Main Window'));
% 
% % Select data in interface
% data = tool.selected_Studies();
% 
% pip.run(data);

%% VIEW HISTORY
clc
openvar('pip.History')

%% Remove paths

for i = 1:length(paths)
    %rmpath(genpath(paths(i)));
end

%% Finished
disp('Finished');
