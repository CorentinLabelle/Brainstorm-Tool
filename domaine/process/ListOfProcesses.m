classdef ListOfProcesses < ListOfObjects

    properties (GetAccess = public, SetAccess = protected)
        List cell;        
    end
    
    methods (Access = ?Pipeline)
        
        function isEmpty = isEmpty(obj)
            isEmpty = isempty(obj.List);
        end  
        
        function cls = getClass(obj)
            allProcessClass = obj.getProcessClassOfEveryProcess();
            cls = ProcessClass.getProcessClassFromCell(allProcessClass);
        end
        
        function numberOfProcess = getNumberOfProcess(obj)
            numberOfProcess = length(obj.List);
        end
        
        function process = getProcess(obj, index1, index2)
           arguments
               obj ListOfProcesses
               index1 int16 = double.empty()
               index2 int16 = double.empty()
           end
           if isempty(index1)
               process = obj.List;
           elseif isempty(index2)
               process = obj.List{index1};
           else
               assert(index2 > index1, 'The second index must be greater than the first');
               process = obj.List(index1:index2);
           end
        end
        
        function obj = addProcess(obj, processToAdd, position)
            arguments
                obj
                processToAdd cell
                position
            end
            obj.verifyIfDuplicated(processToAdd);
            obj.verifyProcessClassIsValid(processToAdd);
            obj.List = {obj.List{1:position-1}, processToAdd{:,:}, obj.List{position:end}};
        end
        
        function obj = swapProcess(obj, positionSource, positionDestination)
            arguments
                obj ListOfProcesses
                positionSource int64 {mustBeNonempty}
                positionDestination int64 {mustBeNonempty}
            end
            obj.List([positionSource, positionDestination]) = obj.List([positionDestination, positionSource]);
        end
        
        function obj = moveProcess(obj, oldPosition, newPosition)
            processToMove = obj.List{oldPosition};           
            obj = obj.deleteProcess(oldPosition);
            obj = obj.addProcess(processToMove, newPosition);
        end

        function obj = remove(obj, index)
            obj.List(index) = [];
        end
           
        function index = getProcessIndexWithName(obj, processNameToFind)
            processNameToFind = Process.formatProcessName(processNameToFind);
            index = find(processNameToFind == obj.getNames());
            if isempty(index)
                index = 0;
            end
        end
        
        function isIn = isProcessInWithName(obj, processName)
            isIn = any(obj.getProcessIndexWithName(processName) > 0);
        end
        
        function index = getProcessIndex(obj, process)
            index = find(cellfun(@(x) x == process, obj.List)); 
            if isempty(index)
                index = 0;
            end
        end
        
        function isIn = isProcessIn(obj, process)
            arguments
                obj ListOfProcesses
                process cell
            end
            isIn = false(size(process));
            for i = 1:size(isIn, 1)
                for j = 1:size(isIn, 2)
                    isIn(i,j) = obj.getProcessIndex(process{i,j}) > 0;
                end
            end
        end

        function processesAsChars = convertToCharacters(obj)
            processesAsChars = char(strjoin(obj.convertToString(), '\n\n'));
        end
        
    end
    
    methods (Access = public)
         
        function disp(obj)
            disp(obj.convertToCharacters());
        end
        
    end
    
    methods (Access = private)
        
        function names = getNames(obj)
            if obj.isEmpty()
                names = string();
            else
                names = string(cellfun(@(x) x.getName(), obj.List));
            end            
        end
        
        function allProcessClass = getProcessClassOfEveryProcess(obj)
            if obj.isEmpty()
                allProcessClass = ProcessClass.empty;
            else
                allProcessClass = cellfun(@(x) x.getClass(), obj.List);
            end
        end
                       
        function verifyProcessClassIsValid(obj, process)
            currentProcessClass = obj.getClass();
            if isempty(currentProcessClass)
                return
            end
            processClassToAdd = cellfun(@(x) class(x), process, 'UniformOutput', false);            
            switch currentProcessClass
                case ProcessClass.EegProcess
                    containMeg = any(contains(processClassToAdd, char(ProcessClass.MegProcess)));
                    assert(~containMeg, 'Cannot add MEG process to EEG pipeline.');
                case ProcessClass.MegProcess
                    containEeg = any(contains(processClassToAdd, char(ProcessClass.EegProcess)));
                    assert(~containEeg, 'Cannot add EEG process to MEG pipeline.');
            end
        end
        
        function verifyIfDuplicated(obj, process)
            if any(obj.isProcessIn(process))
                error('A process is duplicated.');
            end
        end
        
        function processesAsString = convertToString(obj)
            processesAsString = strings(1, obj.getNumberOfProcess());
            for i = 1:obj.getNumberOfProcess()
                processesAsString(i) = obj.getProcess(i).convertToCharacters();
            end
        end
        
    end
    
end