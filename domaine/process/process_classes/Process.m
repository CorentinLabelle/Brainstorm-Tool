classdef Process
    
    properties (SetAccess = private, GetAccess = public)
        Details ProcessDetails;
        Parameters ListOfParameters
    end
    
    methods (Access = ?ProcessFactory)
        
        function obj = setName(obj, name)
            obj.Details = obj.Details.setName(name);
        end
        
        function obj = setAnalyzerFct(obj, analyzerFct)
            obj.Details = obj.Details.setAnalyzerFct(analyzerFct);
        end
        
        function obj = setfName(obj, fName)
            obj.Details = obj.Details.setfName(fName);
        end
        
    end
    
    methods (Access = public)
        
        function obj = Process(~)
            if nargin == 0
                obj.Details = ProcessDetails();
                obj.Parameters = ListOfParameters();
            else
                error([ 'To create a process, use the following synthax:' newline ...
                        'Process.create()']);
            end            
        end
        
        function name = getName(obj)
            name = obj.Details.getName();
        end
        
        function cls = getClass(obj)
            cls = ProcessClass.fromChar(class(obj));
        end
        
        function date = getDate(obj)
            date = obj.Details.getDate();
        end

        function analyzerFct = getAnalyzerFct(obj)
            analyzerFct = obj.Details.getAnalyzerFct();
        end
        
        function fName = getfName(obj)
            fName = obj.Details.getfName();
        end
        
        function documentation = getDocumentation(obj)
            documentation = obj.Details.Documentation;
        end

        function sProcess = getSProcess(obj)
            sProcess = obj.Details.getSProcess();
        end
                
        function obj = setDocumentation(obj, documentation)
            obj.Details = obj.Details.setDocumentation(documentation);
        end
        
        function openWebDocumentation(obj)
            web(obj.getSProcess().Description);    
        end
        
        function obj = setListOfParameters(obj, parameters)
            obj.Parameters = obj.Parameters.setList(parameters); 
        end
        
        function obj = addParameter(obj, parameter)
            obj.Parameters = obj.Parameters.add(parameter);
        end
        
        function obj = removeParameter(obj, nameOrIndex)
            obj.Parameters = obj.Parameters.remove(nameOrIndex);
        end
        
        function obj = clearParameter(obj)
            obj.Parameters = obj.Parameters.clear();
        end
        
        function obj = setParameter(obj, nameOrIndex, valueToSet)
            obj.Parameters = obj.Parameters.setValue(nameOrIndex, valueToSet);
        end
        
        function obj = setParameterWithStructure(obj, structure)
            obj.Parameters = obj.Parameters.setValueWithStructure(structure);
        end
        
        function parameter = getParameter(obj, nameOrIndex)
            arguments
                obj
                nameOrIndex = [];
            end
            if isempty(nameOrIndex)
                parameter = obj.Parameters;
            else
                parameter = obj.Parameters.getValue(nameOrIndex);
            end
        end
        
        function isEqual = eq(obj, process)
            isEqual = ...
                strcmpi(obj.getName(), process.getName()) && ...
                isequal(obj.getParameter(), process.getParameter());  
        end
        
        function isNotEqual = ne(obj, process)
            isNotEqual = ~(obj == process);
        end
        
        function sFilesOut = run(obj, sFilesIn)
            arguments
                obj Process
                sFilesIn = [];
            end            
            if ~isa(sFilesIn, 'struct') && ~isempty(sFilesIn)
                sFilesIn = SFileManager.getsFileFromMatLink(sFilesIn);
            end
            analyzerFunction = obj.getAnalyzerFct();
            sFilesOut = analyzerFunction(obj.getAnalyzer(), obj.getParameter(), sFilesIn);
        end
        
        function disp(obj)
            disp(obj.convertToCharacters());
        end
        
        function processAsCharacters = convertToCharacters(obj)
            processAsCharacters = [...
                '<strong>' char(obj.getName()) '</strong>' ...
                newline obj.Parameters.convertToCharacters()];
        end
        
        function json = jsonencode(obj, varargin)
            s = struct();
            s.Name = obj.getName();
            s.Parameters = obj.getParameter();
            json = jsonencode(s, varargin{:});
        end
        
        function objAsCell = cell(obj)
            objAsCell = {obj};
        end
        
    end

    methods (Static, Access = public)
        
        function process = create(input)
            if nargin == 0
                error('An input is needed to create a Process.');
            else
                process = ProcessFactory.create(input);
            end
        end
        
        function prName = formatProcessName(prName)
            prName = strtrim(lower(char(prName)));
            prName = strrep(prName, ' ', '_');
            prName = strrep(prName, '-', '_');
        end
                
        function printAllProcesses()
            ProcessPrinter.printAvailableProcesses();
        end
        
    end
   
end