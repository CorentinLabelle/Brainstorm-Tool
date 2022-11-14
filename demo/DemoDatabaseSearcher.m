%% Demo of to use the DatabaseSearcher
clear
clc

% Display instructions
DatabaseSearcher.getInstruction();

%% Setup
protocolName = 'DemoProtocol';
subjectName = {'Robert', 'Lewandwoski'};
rawFilesPath = {...
    {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg'}, ...
    {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b3.eeg', ...
    '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b4.eeg'}
    };

if ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.deleteProtocol(protocolName);
end
ProtocolManager.createProtocol(protocolName);

for i = 1:length(subjectName)
    rrf = Process.create('review raw files');
    rrf = rrf.setParameter('subject', subjectName{i});
    rrf = rrf.setParameter('raw files', rawFilesPath{i});
    rrf = rrf.setParameter('file_format', 2);
    rrf.run([]);
end

sFile1 = DatabaseSearcher.getAllsFiles();
nf = Process.create('notch filter');
nf = nf.setParameter(1, [60 120 180]);
sFile2 = nf.run(sFile1);

nf = Process.create('band pass filter');
nf = nf.setParameter(1, [4 30]);
sFile3 = nf.run(sFile2);

pwsd = Process.create('power spectrum density');
pwsd = pwsd.setParameter(1, 10);
sFile4 = pwsd.run(sFile3);

%%

% Get all power spectrum density (psd) file
allPsd = DatabaseSearcher.searchQuery('path', 'contains', 'psd');

% Get psd for one subject
psdOneSubject = DatabaseSearcher.searchQuery('path', 'contains', 'Robert', 'and', ...
                                'path', 'contains', 'psd');
    
%% End
endMessage;