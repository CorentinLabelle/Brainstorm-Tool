classdef ProtocolManagerTester < matlab.unittest.TestCase    
    
    properties (Access = private)
        allProtocols = ProtocolManager.getAllProtocols(); 
        nbProtocol = length(ProtocolManager.getAllProtocols());
        newProtocolName = 'proto_tester';
    end
    
    methods (TestMethodSetup)
    end
    
    methods (TestMethodTeardown)
    end
    
    methods (Test)
        
        function isProtocolCreated(tc)
            
            for i = 1:tc.nbProtocol
                protocolName = tc.allProtocols{i};
                tc.verifyTrue(ProtocolManager.isProtocolAlreadyCreated(protocolName), ['Failed with protocol "' protocolName '"']);
            end

            unknownProtocol = 'This_protocol_has_never_been_created';
            tc.verifyTrue(~ProtocolManager.isProtocolAlreadyCreated(unknownProtocol));
            
        end
        
        function createProtocol(tc)
           
            if ProtocolManager.isProtocolAlreadyCreated(tc.newProtocolName)
                ProtocolManager.deleteProtocol(tc.newProtocolName);
            end
            tc.verifyTrue(~ProtocolManager.isProtocolAlreadyCreated(tc.newProtocolName));
            
            ProtocolManager.createProtocol(tc.newProtocolName);
            
            tc.verifyTrue(ProtocolManager.isProtocolAlreadyCreated(tc.newProtocolName));
            tc.verifyTrue(strcmpi(bst_get('ProtocolInfo').Comment, tc.newProtocolName));
            
        end
        
        function deleteProtocol(tc)
            
            if ~ProtocolManager.isProtocolAlreadyCreated(tc.newProtocolName)
                ProtocolManager.createProtocol(tc.newProtocolName);
            end
            
            tc.verifyTrue(ProtocolManager.isProtocolAlreadyCreated(tc.newProtocolName));
            ProtocolManager.deleteProtocol(tc.newProtocolName);
            tc.verifyTrue(~ProtocolManager.isProtocolAlreadyCreated(tc.newProtocolName));
            
        end
        
        function getProtocolIndex(tc)
           
            for i = 1:tc.nbProtocol
                protocolName = tc.allProtocols{i};
                protocolIdx = ProtocolManager.getProtocolIndex(protocolName);
                tc.verifyTrue(~isempty(protocolIdx), ['Failed with protocol "' protocolName '"']);
            end

            protocolIdx = ProtocolManager.getProtocolIndex(unknownProtocol);
            tc.verifyTrue(isempty(protocolIdx));
            
        end
        
        function setProtocol(tc)
           
            for i = 1:tc.nbProtocol
                protocolName = tc.allProtocols{i};
                protocolIdx = ProtocolManager.getProtocolIndex(protocolName);

                tc.verifyTrue(~strcmpi(bst_get('ProtocolInfo').Comment, protocolName));
                ProtocolManager.setProtocol(protocolIdx);
                tc.verifyTrue(strcmpi(bst_get('ProtocolInfo').Comment, protocolName));

            end
            
        end
        
    end
    
end