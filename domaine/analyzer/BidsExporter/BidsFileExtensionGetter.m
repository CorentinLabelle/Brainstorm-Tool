classdef BidsFileExtensionGetter
    
    methods (Static, Access = public)
        
        function extension = getProvenanceExtension()
            extension = '.json';
        end
        
        function extension = getEventExtension()
            extension = '.tsv';
        end
        
        function extension = getEventMetaDataExtension()
            extension = '.json';
        end
        
        function extension = getChannelExtension()
            extension = '.tsv';
        end
        
        function tag = getElectrodeExtension()
            tag = '.tsv';
        end
        
        function extension = getCoordinateExtension()
            extension = '.tsv';
        end
        
    end
end