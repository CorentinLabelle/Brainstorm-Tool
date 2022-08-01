classdef ProcessFactory
    
    methods (Static, Access = {?Process, ?ProcessValidator})
        
        function obj = ProcessFactory()
        end
        
        function processes = create(input)
                        
            if isa(input, 'Process')
                processes = input;
                return
            elseif ischar(input) || isstring(input)
                input = string(input);
            end
            
            constructorHandle = ProcessFactory.getConstructor(input);
            
            validator = ProcessValidator();
            validator.verifyIfCtorIsValid(constructorHandle);
            
            if isscalar(input)
                processes = ProcessFactory.createScalar(input, constructorHandle);
            else
                processes = ProcessFactory.createCell(input, constructorHandle);
            end
            
        end
        
    end
    
    methods (Static, Access = private)
        
        function process = createScalar(input, ctorHandle)
            
            process = ctorHandle(input);
            
        end
        
        function processes = createCell(input, ctorHandle)
            
            m = size(input, 1);
            n = size(input, 2);
            processes = cell(m,n);
            for i = 1:m
                for j = 1:n
                    processes{i,j} = ctorHandle(input(i,j));
                end
            end
            
        end
        
        function process = ctorWithName(prName)
            
           prName = Process.formatProcessName(prName);
           
           validator = ProcessValidator();
           validator.verifyName(prName);
           
           processInfoGetter = ProcessDefaultInfoGetter();
           cls = processInfoGetter.getPrClsWithPrName(prName);
           initializedParameterStruct = processInfoGetter.getInitializedPrStruct(prName);
           
           clsCtor = str2func(cls);
           process = clsCtor();
           process.Name = prName;
           process.Parameters = initializedParameterStruct.Parameter;
           process.AnalyzerFct = initializedParameterStruct.AnalyzerFct;
           process.fName = initializedParameterStruct.fName;
            
        end
        
        function process = ctorWithStructure(prStruct)
            
            prStruct.Name = Process.formatProcessName(prStruct.Name);
            process = ProcessFactory.ctorWithName(prStruct.Name);
            process = ProcessFactory.fillEmptyProcessWithStructure(process, prStruct);
            ProcessFactory.switchColumnParameterToVector(process);
               
        end
        
        function process = ctorWithCell(prCell)
                      
            assert(length(prCell) == 1);
            process = ProcessFactory.create(prCell{1});
            
            %process = ProcessFactory.ctorWithStructure(prCell{1});    
            
        end
        
        function ctorHandle = getConstructor(input)
            
            ctorHandle = function_handle.empty;
            
            if isstruct(input)
                ctorHandle = @ProcessFactory.ctorWithStructure;
            elseif ischar(input) || isstring(input)
                ctorHandle = @ProcessFactory.ctorWithName;
            elseif iscell(input)
                ctorHandle = @ProcessFactory.ctorWithCell;
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
       
%         function orderedProcessCls = orderProcessClassWithPrecedence()
%            
%             processCls = Process.getProcessClasses();
%             metaClsArray = arrayfun(@meta.class.fromName, processCls);
%             nbInfCls = arrayfun(@(x) length(x.InferiorClasses), metaClsArray);
%             
%             [~, sortedIndex] = sort(nbInfCls, 'descend');
% 
%             orderedProcessCls = processCls(sortedIndex);
%            
%         end
        
    end
    
    methods (Static, Access = ?ProcessConverter)
        
%         function matrix = convertCellToMat(cellProcess)
%             
%             classContent =  unique(...
%                             string(...
%                             cellfun(@class, cellProcess, 'UniformOutput', false)));
%             
%             orderedClasses = ProcessFactory.orderProcessClassWithPrecedence();
%             
%             for i = 1:length(orderedClasses)
%                 if any(strcmpi(orderedClasses(i), classContent))
%                     finalCls = orderedClasses(i);
%                     break
%                 end
%             end
%             
%             matrix = cellfun(@(x) x.cast(finalCls), cellProcess);
%             
%         end
       
        function process = fillEmptyProcessWithStructure(emptyPr, prStruct)         
            
            metaClassProcess = ?Process;
            props = {metaClassProcess.PropertyList.Name};
            
            validFields = intersect(props, fieldnames(prStruct));
            
            for i = 1:length(validFields)
                currentProperty = validFields{i};
                if strcmpi(currentProperty, 'Parameters')
                    emptyPr.setParameterWithStructure(prStruct.(currentProperty));
                else
                    emptyPr.(currentProperty) = prStruct.(currentProperty);
                end
                
            end
            process = emptyPr;
            
        end
        
%         function process = fillEmptyProcessWithProcess(emptyPr, refPr) 
%         
%             metaClassProcess = ?Process;
%             props = {metaClassProcess.PropertyList.Name};
%             for i = 1:length(props)
%                 currentProperty = props{i};
%                 %if strcmpi(currentProperty, "Type")
%                     %continue
%                 %end
%                 emptyPr.(currentProperty) = refPr.(currentProperty);
%             end
%             process = emptyPr;
%             
%         end
        
    end
    
end