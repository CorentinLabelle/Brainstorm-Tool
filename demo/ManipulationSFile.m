%% Manipulation of sFile
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
rrf = rrf.setParameter('subjects', {'Robert'});
rrf = rrf.setParameter('raw files', {rawFilesPath});
rrf = rrf.setParameter('file_format', 2);
sFile1 = rrf.run([]);

nf = Process.create('notch filter');
nf = nf.setParameter(1, [60 120 180]);
sFile2 = nf.run(sFile1);

%%

% Check if sFile is raw
isRaw1 = SFileManager.isSFileRaw(sFile1);
isRaw2 = SFileManager.isSFileRaw(sFile2);
assert(isRaw1);
assert(~isRaw2);

% Get study path from sFile
studyPath1 = SFileManager.getStudyPathFromSFile(sFile1);
studyPath2 = SFileManager.getStudyPathFromSFile(sFile2);
assert(ischar(studyPath1));
assert(ischar(studyPath2));

% Check if study link
isLink1 = SFileManager.isStudyLink(sFile1);
isLink2 = SFileManager.isStudyLink(sFile2);
isLink3 = SFileManager.isStudyLink(studyPath1);
isLink4 = SFileManager.isStudyLink(studyPath2);
assert(~isLink1);
assert(~isLink2);
assert(isLink3);
assert(isLink4);

% Get sFile from study path
sFile1_ = SFileManager.getsFileFromMatLink(studyPath1);
sFile2_ = SFileManager.getsFileFromMatLink(studyPath2);
assert(isequal(sFile1, sFile1_));
assert(isequal(sFile2 ,sFile2_));

% Get data type from sFile
dataType1 = SFileManager.getSensorTypeFromsFile(sFile1);
dataType2 = SFileManager.getSensorTypeFromsFile(sFile2);
assert(strcmp(dataType1, 'eeg'));
assert(strcmp(dataType2, 'eeg'));

% Get brainstormstudy.mat path from sFile
bstmat1 = SFileManager.getBrainstormStudyPathFromSFile(sFile1);
bstmat2 = SFileManager.getBrainstormStudyPathFromSFile(sFile2);
assert(ischar(bstmat1));
assert(ischar(bstmat2));
    
%% End
endMessage;