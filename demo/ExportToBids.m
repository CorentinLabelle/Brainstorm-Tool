%% Export To BIDS
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

%% Export to BIDS
etb = Process.create('Export to BIDS');
etb = etb.setParameter(1, fullfile(fileparts(mfilename('fullpath')), 'bids', 'bids'));
etb = etb.setParameter(2, 'The Cervo Project');
etb = etb.setParameter(3, 'CERVO-2022');
etb = etb.setParameter(4, 'The Best Project Ever');
etb = etb.setParameter(5, 'People at CERVO are awesome.');
etb = etb.setParameter(6, 'The task was to do something very interesting.');
etb = etb.setParameter(7, struct('new_dataset_desc_field', 'a description'));
etb = etb.setParameter(8, struct('new_dataset_sidecar_field', 'a description'));
etb.run(sFile2);
    
%% End
endMessage;