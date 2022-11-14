%% Import Anatomy
clear
clc

%% Setup
protocolName = 'DemoProtocol';

if ~ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.createProtocol(protocolName);
end

%% Import Anatomy (meg)
anatomyFolder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/sample_introduction/anatomy';

ia = Process.create('import anatomy');
ia = ia.setParameter(1, 'Georges');
ia = ia.setParameter(2, anatomyFolder);
ia = ia.setParameter(3, 2);
sFile1 = ia.run();

%% Import Anatomy (eeg)
anatomyFolder = '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/sample_epilepsy/anatomy';

ia = Process.create('import anatomy');
ia = ia.setParameter(1, 'Georges');
ia = ia.setParameter(2, anatomyFolder);
ia = ia.setParameter(3, 1);
sFile2 = ia.run();
    
%% End
endMessage;