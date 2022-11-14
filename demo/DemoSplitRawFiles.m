%% Split raw files
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

%% Split raw files
sFile = DatabaseSearcher.searchQuery('path', 'contains', 'b1', 'and', 'path', 'contains', 'Pedri');
eventName = 'S  4';
srf = Process.create('split raw files');
srf = srf.setParameter(1, eventName);
sFileOut = srf.run(sFile);

