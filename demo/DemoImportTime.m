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

%% Import time

% Full window
sFile = DatabaseSearcher.searchQuery('type', 'equals', 'RawData', 'and', 'path', 'contain', 'b1');
it = Process.create('import time');
it.run(sFile);

% Specific window
sFile = DatabaseSearcher.searchQuery('type', 'equals', 'RawData', 'and', 'path', 'contain', 'b1');
it = Process.create('import time');
it = it.setParameter(1, [10 20]);
it.run(sFile);

% With end point
sFile = DatabaseSearcher.searchQuery('type', 'equals', 'RawData', 'and', 'path', 'contain', 'b1');
it = Process.create('import time');
it = it.setParameter(1, [0 10]);
it.run(sFile);

% With start point
sFile = DatabaseSearcher.searchQuery('type', 'equals', 'RawData', 'and', 'path', 'contain', 'b1');
it = Process.create('import time');
it = it.setParameter(1, 500);
it.run(sFile);


%% Import time for multiple sFile (NOT WORKING)

sFile = DatabaseSearcher.searchQuery('type', 'equals', 'RawData');
it = Process.create('import time');
it = it.setParameter(1, [30 70]);
it.run(sFile(1));
