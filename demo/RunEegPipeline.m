%% Run EEG Pipeline
clear
clc

%% Setup
protocolName = 'DemoProtocol';
if ~ProtocolManager.isProtocolCreated(protocolName)
    ProtocolManager.createProtocol(protocolName);
end

%% Run Pipeline
eegPip = EegPipelineNoIca();
sFile = eegPip.run();
    
%% End
endMessage;