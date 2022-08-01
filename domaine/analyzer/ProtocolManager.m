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
           
            contentOfDatabase = dir(bst_get('BrainstormDbDir'));
            allProtocols = {contentOfDatabase.name};
            allProtocols = allProtocols(~strcmpi(allProtocols, '.'));
            allProtocols = allProtocols(~strcmpi(allProtocols, '..'));
            
        end
                 
        function deleteProtocol(ProtocolName)
            
            gui_brainstorm('DeleteProtocol', ProtocolName);
            
        end
        
%         function allProtocols = getAllProtocols()
%             % Return cell of the protocol structure for every protocol
%             
%             % Save index of current Protocol
%             originalProtocol = bst_get('iProtocol');
%                         
%             index = 1;
%             while true
%                 bst_set('iProtocol', index);
%                 
%                 protocol = bst_get('ProtocolInfo');
%                 if isempty(protocol)
%                     break
%                 end
%                 allProtocols{index} = protocol.Comment;
%                 
%                 index = index + 1;
%             end
%             
%             bst_set('iProtocol', originalProtocol);
%             
%         end

                
        
    end
end

