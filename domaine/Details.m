classdef Details
    
    properties (SetAccess = protected, GetAccess = public)
        Name (1,1) string = strings(1,1);
        DateOfCreation datetime = datetime;
        Documentation char = char.empty;
    end
    
    methods (Access = public)
        
        function obj = setName(obj, name)
            assert(ischar(name) || isstring(name));
            obj.Name = name;
        end
        
        function name = getName(obj)
            name = obj.Name;
        end
        
        function obj = setDate(obj, dateOfCreation)
            obj.DateOfCreation = dateOfCreation;
        end
        
        function dateOfCreation = getDate(obj)
            dateOfCreation = obj.DateOfCreation;
        end
        
        function obj = setDocumentation(obj, documentation)
            assert(ischar(documentation) || isstring(documentation));
            obj.Documentation = documentation;
        end
        
        function documentation = getDocumentation(obj)
            documentation = obj.Documentation;
        end
        
    end
    
    methods
        
        function obj = set.Name(obj, name)
            obj.Name = name;           
        end      
               
        function obj = set.DateOfCreation(obj, date)
            obj.DateOfCreation = date;           
        end
        
        function obj = set.Documentation(obj, documentation)
            obj.Documentation = documentation;
        end
        
        function doc = get.Documentation(obj)
            if isempty(obj.Documentation)
                doc = 'No Documentation';
            else
                doc = obj.Documentation;
            end                  
        end
        
    end
end