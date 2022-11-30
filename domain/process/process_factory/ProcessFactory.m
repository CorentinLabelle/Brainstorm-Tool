classdef ProcessFactory
    
    methods (Static, Access = ?Process)
        
        function obj = ProcessFactory()
        end
        
        function processes = create(input)
            if isa(input, 'Process')
                processes = input;
                return
            end
            
            if ischar(input)
                input = string(input);
            end
            
            constructorHandle = ProcessFactory.getConstructor(input);            
            if isscalar(input)
                processes = ScalarCreator.createScalar(constructorHandle, input);
            else
                processes = CellCreator.createCell(constructorHandle, input);
            end            
        end
        
    end
    
    methods (Static, Access = private)
     
        function process = ctorWithName(prName)
            prName = Process.formatProcessName(prName);
            database = Database();
            prCls = database.getProcessClass(prName);
            processDetails = database.getProcessDetails(prName);
            listOfParameters = database.getListOfParameters(prName);

            process = prCls.instantiate();
            process = process.setName(prName);
            process = process.setListOfParameters(listOfParameters());
            process = process.setAnalyzerFct(processDetails.AnalyzerFct);
            process = process.setfName(processDetails.fName);
        end
        
        function process = ctorWithStructure(prStruct)
            prStruct.Name = Process.formatProcessName(prStruct.Name);
            process = ProcessFactory.ctorWithName(prStruct.Name);
            process = process.setParameterWithStructure(prStruct.Parameters);
        end
        
        function process = ctorWithCell(prCell)
            assert(length(prCell) == 1);
            process = ProcessFactory.create(prCell{1});
        end
        
        function ctorHandle = getConstructor(input)
            if isstruct(input)
                ctorHandle = @ProcessFactory.ctorWithStructure;
            elseif ischar(input) || isstring(input)
                ctorHandle = @ProcessFactory.ctorWithName;
            elseif iscell(input)
                ctorHandle = @ProcessFactory.ctorWithCell;
            else
                error('Invalid input to create a Process');
            end            
        end
        
        function switchColumnParameterToVector(process)
            
           fields = fieldnames(process.Parameters);
           for i = 1:length(fields)
               param = process.Parameters.(fields{i});
               if iscolumn(param)
                   process.Parameters.(fields{i}) = param';
               end               
           end
           
        end
        
    end
    
end