%% Import time
clear
clc

%% Setup
protocolName = 'DemoProtocol';
rawFilesPath = ...
    {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg'};

if ~ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.createProtocol(protocolName);
end

rrf = Process.create('review raw files');
rrf = rrf.setParameter('subject', 'Robert');
rrf = rrf.setParameter('raw files', rawFilesPath);
rrf = rrf.setParameter('file_format', 2);
sFile1 = rrf.run([]);

% Add eeg position
sFile = DatabaseSearcher.getAllsFiles();
aep = Process.create('add eeg position');
aep = aep.setParameter(3, 1);
aep.run(sFile);

% Import
sFile = DatabaseSearcher.searchQuery('path', 'contains', 'b1', 'and', 'type', 'equals', 'RawData');
it = Process.create('import time');
it.run(sFile);



%% Detect bad channel
sFile = DatabaseSearcher.searchQuery('type', 'equals', 'Data');
rbt = Process.create('Reject bad trials');
rbt = rbt.setParameter(3, [1, 1.5]);
rbt.run(sFile);

