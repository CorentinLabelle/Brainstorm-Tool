%% Manipulate protocol
clear
clc

protocolName = 'DemoProtocol';

% Delete protocol
ProtocolManager.deleteProtocol(protocolName);

% Get all protocols
allProtocols = ProtocolManager.getAllProtocols();
disp(allProtocols);

% Create protocol
ProtocolManager.createProtocol(protocolName);

% Check if protocol exists
exists = ProtocolManager.isProtocolCreated(protocolName);
assert(exists);

% Get Protocol Index
index = ProtocolManager.getProtocolIndex(protocolName);

% Set Protocol

    % with index
    ProtocolManager.setProtocol(index);
    
    % with name
    ProtocolManager.setProtocolWithName(protocolName);
    
% Reload Protocol

    % with index
    ProtocolManager.reloadProtocol(index);
    
    % with name
    ProtocolManager.reloadProtocolWithName(protocolName);
    
% Delete protocol
ProtocolManager.deleteProtocol(protocolName);
    
%% End
endMessage;