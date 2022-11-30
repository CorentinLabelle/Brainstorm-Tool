classdef ProcessClass
    enumeration
        EegProcess, MegProcess, GeneralProcess, SpecificProcess
    end
    
    methods (Access = public)
    
        function instance = instantiate(obj)
            instance = eval(char(obj)); 
        end
        
    end
    
    methods (Static, Access = public)
       
        function processClass = fromChar(characters)
            characters = lower(characters);
            switch characters
                case 'eegprocess'
                    processClass = ProcessClass.EegProcess;
                case 'megprocess'
                    processClass = ProcessClass.MegProcess;
                case 'generalprocess'
                    processClass = ProcessClass.GeneralProcess;
                case 'specificprocess'
                    processClass = ProcessClass.SpecificProcess;
                otherwise
                    error([ 'Invalid class (' characters ').' newline ...
                            'Cannot convert characters to a process class.']);
            end
        end
        
        function processClass = fromString(str)
            processClass = ProcessClass.fromChar(char(str));
        end
        
        function processClass = getProcessClassFromCell(cell)
            if isempty(cell)
                processClass = ProcessClass.empty();
            elseif any(cell == ProcessClass.EegProcess)
                processClass = ProcessClass.EegProcess;
            elseif any(cell == ProcessClass.MegProcess)
                processClass = ProcessClass.MegProcess;
            elseif any(cell == ProcessClass.SpecificProcess)
                processClass = ProcessClass.SpecificProcess;
            elseif any(cell == ProcessClass.GeneralProcess)
                processClass = ProcessClass.GeneralProcess;
            else
                processClass = ProcessClass.empty();
            end   
        end
        
    end
    
end