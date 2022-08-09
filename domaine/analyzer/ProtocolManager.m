classdef ProtocolManager < handle
    
    methods (Static, Access = public)
        
        function createProtocol(protocolName)
            
            gui_brainstorm('CreateProtocol', protocolName, 0, 0);
            
        end
        
        function isCreated = isProtocolCreated(protocolName)
            
            allProtocols = ProtocolManager.getAllProtocols();
            isCreated = any(strcmpi(allProtocols, protocolName));
            
        end
        
        function setProtocol(protocolIndex)

            bst_set('iProtocol', protocolIndex);
            gui_brainstorm('SetCurrentProtocol', protocolIndex);

        end

        function protocolIndex = getProtocolIndex(protocolName)

            protocolIndex = bst_get('Protocol', protocolName);

        end
        
        function allProtocols = getAllProtocols()
           
%             contentOfDatabase = dir(bst_get('BrainstormDbDir'));
%             allProtocols = {contentOfDatabase.name};
%             allProtocols = allProtocols(~strcmpi(allProtocols, '.'));
%             allProtocols = allProtocols(~strcmpi(allProtocols, '..'));
            global GlobalData
            allProtocols = {GlobalData.DataBase.ProtocolInfo.Comment};
            
        end
                 
        function deleteProtocol(ProtocolName)
            
            gui_brainstorm('DeleteProtocol', ProtocolName);
            
        end               
        
    end
    
end