classdef ProtocolManager < handle
    
    methods (Static, Access = public)
        
        function createProtocol(protocolName)            
            gui_brainstorm('CreateProtocol', protocolName, 0, 0);            
        end
        
        function isCreated = isProtocolCreated(protocolName)            
            allProtocols = ProtocolManager.getAllProtocols();
            isCreated = any(strcmpi(allProtocols, protocolName));            
        end
        
        function reloadProtocol(protocolIndex)            
            db_reload_database(protocolIndex);            
        end
        
        function reloadProtocolWithName(protocolName)            
            db_reload_database(ProtocolManager.getProtocolIndex(protocolName));            
        end
        
        function setProtocol(protocolIndex)
            bst_set('iProtocol', protocolIndex);
            gui_brainstorm('SetCurrentProtocol', protocolIndex);
        end
        
        function setProtocolWithName(protocolName)
            protocolIndex = ProtocolManager.getProtocolIndex(protocolName);
            bst_set('iProtocol', protocolIndex);
            gui_brainstorm('SetCurrentProtocol', protocolIndex);
        end

        function protocolIndex = getProtocolIndex(protocolName)
            protocolIndex = bst_get('Protocol', protocolName);
        end
        
        function allProtocols = getAllProtocols()
            global GlobalData
            allProtocols = {GlobalData.DataBase.ProtocolInfo.Comment};            
        end
                 
        function deleteProtocol(ProtocolName)            
            gui_brainstorm('DeleteProtocol', ProtocolName);            
        end               
        
    end
    
end