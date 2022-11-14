%% Export data
clear
clc

%% Setup
protocolName = 'DemoProtocol';
rawFilesPath = ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg';

if ~ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.createProtocol(protocolName);
end

rrf = Process.create('review raw files');
rrf = rrf.setParameter('subject', 'Robert');
rrf = rrf.setParameter('raw files', {rawFilesPath});
rrf = rrf.setParameter('file_format', 2);
sFile1 = rrf.run([]);

nf = Process.create('notch filter');
nf = nf.setParameter(1, [60 120 180]);
sFile2 = nf.run(sFile1);

%% Folder to export
folderToExport = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/demo/export';

%% Export data to EDF

ed = Process.create('Export Data');
ed = ed.setParameter(1, folderToExport);
ed = ed.setParameter(2, 5);
sFile1_EDF = ed.run(sFile1);
sFile2_EDF = ed.run(sFile2);

%% Export data to Brainvision

ed = Process.create('Export Data');
ed = ed.setParameter(1, folderToExport);
ed = ed.setParameter(2, 2);
sFile1_Brainvision = ed.run(sFile1);
sFile2_Brainvision = ed.run(sFile2);
    
%% End
endMessage;