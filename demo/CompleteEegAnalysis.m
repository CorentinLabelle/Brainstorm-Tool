%% AllProcessTester
clear
clc

%% Open Brainstorm
if ~brainstorm('status')
    brainstorm nogui
end
%% Create (or Set) Protocol
protocolName = 'ProtocolForTest';

if ~ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.createProtocol(protocolName);
else
    ProtocolManager.setProtocolWithName(protocolName);    
end

% Verification
assert(isequal(bst_get('ProtocolInfo').Comment, protocolName));

%% Variables
subjectName = {'Harry', 'Frodo'};
rawFiles = {{'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
            '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg', ...
            '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b3.eeg'}, ...
            {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b4.eeg', ...
            '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b5.eeg', ...
            '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b6.eeg', ...
            }};

%% Create Subject
cs = Process.create('create subject');
cs = cs.setParameter(1, subjectName);
cs.run();

% Verification
listOfCurrentSubject = {bst_get('ProtocolSubjects').Subject.Name};
assert(isequal(listOfCurrentSubject, subjectName));

%% Review Raw Files
rrf = Process.create('review raw files');
rrf = rrf.setParameter(1, subjectName);
rrf = rrf.setParameter(2, rawFiles);
rrf = rrf.setParameter(3, 2);
sFiles = rrf.run();

% Verification
files = DatabaseSearcher.getAllsFiles();
assert(isequal(files, sFiles));

%% Add EEG position
sFiles = DatabaseSearcher.getAllsFiles();

for i = 1:length(sFiles)
    channelFile = load(ChannelManager.getChannelFilePath(sFiles(i)));
    assert(all(cellfun(@(x) isequal(x, [0;0;0]), {channelFile.Channel.Loc})))
end

aep = Process.create('add eeg position');
aep = aep.setParameter(3, 1);
sFiles = aep.run(sFiles);

% Verification
for i = 1:length(sFiles)
    channelFile = load(ChannelManager.getChannelFilePath(sFiles(i)));
    assert(any(cellfun(@(x) ~isequal(x, [0;0;0]), {channelFile.Channel.Loc})))
end

%% Refine Registration
sFiles1 = DatabaseSearcher.getAllsFiles();
refineRegistration = RefineRegistration();
refineRegistration.run(sFiles1);

%% Project Electrode On Scalp
sFiles1 = DatabaseSearcher.getAllsFiles();
projectElectrode = ProjectElectrodeOnScalp();
projectElectrode.run(sFiles1);

%% Notch Filter
sFiles1 = DatabaseSearcher.getAllsFiles();
                                    
nf = Process.create('notch filter');
nf = nf.setParameter(1, [60 120 180]);
sFiles1 = nf.run(sFiles1);

sFiles2 = DatabaseSearcher.searchQuery('path', 'contains', 'notch');

assert(isequal(length(sFiles1), length(sFiles2)));

%% Band-Pass Filter
sFiles1 = DatabaseSearcher.getAllsFiles();

bpf = Process.create('band pass filter');
bpf = bpf.setParameter(1, [4 30]);
sFiles1 = bpf.run(sFiles1);

sFiles2 = DatabaseSearcher.searchQuery('path', 'contains', 'band');

assert(isequal(length(sFiles1), length(sFiles2)));

%% Power Spectrum Density
sFiles1 = DatabaseSearcher.searchQuery(   'path', 'contains', 'notch', 'and', ...
                                        'path', 'contains', 'band');
pwsd = Process.create('power spectrum density');
pwsd = pwsd.setParameter(1, 4);
sFiles1 = pwsd.run(sFiles1);

sFiles2 = DatabaseSearcher.searchQuery('path', 'contains', 'psd');

assert(isequal(length(sFiles1), length(sFiles2)));

%% ICA**
sFile1 = DatabaseSearcher.searchQuery(   'path', 'contains', 'notch', 'and', ...
                                        'path', 'contains', 'band', 'and', ...
                                        'path', 'contains', 'rawb1', 'and', ...
                                        'path', 'contains', subjectName{1}, 'and', ...
                                        'type', 'equals', 'RawData');
                                    
ica = Process.create('ica');
ica = ica.setParameter(1, 32);
%sFile2 = ica.run(sFile1);

%assert(isequal(length(sFile1), length(sFile2)));

%% Average Reference
sFile1 = DatabaseSearcher.searchQuery(   'path', 'contains', 'b1', 'and', ...
                                        'path', 'contains', subjectName{1});

ar = Process.create('average reference');
sFile2 = ar.run(sFile1);

assert(isequal(sFile1, sFile2));

%% Export To Bids
sFile1 = DatabaseSearcher.searchQuery(   'path', 'contains', 'b1', 'and', ...
                                        'path', 'contains', subjectName{1});
                                    
etb = Process.create('export to bids');
etb = etb.setParameter(1, '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/demo/bids/bids');
etb = etb.setParameter(2, 'Demo');
etb = etb.setParameter(3, strcat('demo_', char(datetime)));
etb = etb.setParameter(4, 'This is just a demo.');
etb = etb.setParameter(5, 'There is no real participant.');
etb = etb.setParameter(6, 'No real participants means no task.');
datasetDesc = struct();
datasetDesc.Info = 'Name of the dataset';
etb = etb.setParameter(7, datasetDesc);
datasetSidecar = struct();
datasetSidecar.Info = 'No info to add in the sidecars';
etb = etb.setParameter(8, datasetSidecar);

sFile2 = etb.run(sFile1);

assert(isequal(sFile1, sFile2));

%% Import full window
sFile1 = DatabaseSearcher.searchQuery(  'path', 'contains', 'b1', 'and', ...
                                        'path', 'contains', subjectName{1});
it = Process.create('import time');
sFile2 = it.run(sFile1);

assert(isequal(length(sFile1), length(sFile2)));

%% Import events**
sFile1 = DatabaseSearcher.searchQuery(   'path', 'contains', 'b1', 'and', ...
                                        'path', 'contains', subjectName{1});
ie = Process.create('import events');
ie = ie.setParameter(1, 'Mk');
ie = ie.setParameter(2, [-1 1]);
sFile2 = ie.run(sFile1);

%% Delete Protocol
if ProtocolManager.isProtocolCreated(protocolName)
    %ProtocolManager.deleteProtocol(protocolName);
end

assert(~any(contains(ProtocolManager.getAllProtocols(), protocolName)));

%% End
endMessage;