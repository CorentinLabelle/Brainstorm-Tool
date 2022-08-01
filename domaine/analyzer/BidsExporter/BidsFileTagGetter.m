classdef BidsFileTagGetter
        
    methods (Static, Access = public)
        
        function tag = getProvenanceTag()
            tag = '_provenance';
        end
        
        function tag = getEventTag()
            tag = '_events';
        end
        
        function tag = getEventMetaDataTag()
            tag = '_events';
        end
        
        function tag = getChannelTag()
            tag = '_channels';
        end
        
        function tag = getElectrodeTag()
            tag = '_electrodes';            
        end
        
        function tag = getCoordinateTag()            
            tag = '_electrodes2';            
        end
        
    end
end