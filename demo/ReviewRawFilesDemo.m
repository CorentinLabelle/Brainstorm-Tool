%% Review Raw Files
clear
clc

%% Setup
protocolName = 'DemoProtocol';

if ~ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.createProtocol(protocolName);
else
    ProtocolManager.setProtocolWithName(protocolName);
end

%% Review raw files (one subject)
subject = {'Pedri'};
rawFilesPath = ...
    {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg'};

rrf1 = Process.create('review raw files');
rrf1 = rrf1.setParameter(1, subject);
rrf1 = rrf1.setParameter(2, rawFilesPath);
rrf1 = rrf1.setParameter(3, 2);
sFiles1 = rrf1.run();

%% Review raw files (multiple subjects)
subject = {'Robert', 'Lewandowski'};
rawFilesPath = ...
    {{'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg'}, ...
    {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b3.eeg', ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b4.eeg'}};

rrf2 = Process.create('review raw files');
rrf2 = rrf2.setParameter(1, subject);
rrf2 = rrf2.setParameter(2, rawFilesPath);
rrf2 = rrf2.setParameter(3, 2);
sFiles2 = rrf2.run();
