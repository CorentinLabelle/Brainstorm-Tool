classdef ControllerPipelineBuilder < Controller
    
    properties
        
        BidsSearchPath; % [char]
        
    end
    
    methods
        
        function obj = ControllerPipelineBuilder()
            
            obj@Controller();
            
        end
        
        function addProcess(obj, name, structure)
            
            process = obj.createProcess(name, structure);
            obj.CurrentPipeline.addProcess(process);
            
        end
        
        function asgPipelineFolder(obj, folder)
           
            obj.CurrentPipeline.asgFolder(folder);
            
        end
        
        function asgPipelineName(obj, name)
           
            obj.CurrentPipeline.asgName(name);
            
        end
        
        function asgPipelineExtension(obj, extension)
           
            obj.CurrentPipeline.asgExtension(extension);
            
        end
        
        function asgPipelineType(obj, type)
           
            obj.CurrentPipeline.asgType(type);
            
        end
        
        function supportedExtension = getPipelineSupportedExtension(obj)
           
            supportedExtension = obj.CurrentPipeline.getSupportedExtension;
            
        end
        
        function extensions = getPipelineSupportedExtensionToGetFile(obj)
            
            extensions = cellfun(@(x) strcat('*', x), obj.getPipelineSupportedExtension', 'UniformOutput', false);
        
        end
        
        function supportedExtensions = getDatasetSupportedExtension(obj)
           
            switch obj.Type
                
                case 'EEG'
                    supportedExtensions = EEG_Analysis.instance.getExtensionSupported;
                    
                case 'MEG'
                    supportedExtensions = MEG_Analysis.instance.getExtensionSupported;
            
            end
        end
        
        function savePipeline(obj)
            
            obj.CurrentPipeline.save();
            
        end
        
        function asgBidsSearchPath(obj, path)
            
           obj.BidsSearchPath = path;
            
        end
        
        function path = getBidsSearchPath(obj)
            
           path = obj.BidsSearchPath;
            
        end

        function [subjects, rawFilesPath] = addReviewRawFiles(~, subjectName, rawFilesPath)
           
            persistent Subjects RawFilesPath;
            
            if isempty(Subjects)
                Subjects = cell.empty();
            end
            
            if isempty(RawFilesPath)
                RawFilesPath = cell.empty();
            end
            
            if nargin == 1
                subjects = Subjects;
                rawFilesPath = RawFilesPath;
                return
            end
            
            % Add subject
            Subjects(end+1:end+length(subjectName)) = subjectName;
            
            % Add raw files
            classOfCellContent = unique(cellfun(@class, rawFilesPath, 'UniformOutput', false));
            assert(length(classOfCellContent) == 1);
            
            if (strcmp(classOfCellContent{1}, 'cell'))
                RawFilesPath(end+1:end+length(rawFilesPath)) = rawFilesPath;
            else
                RawFilesPath{end+1} = rawFilesPath;
            end
            
        end
        
        function ch = printReviewRawFiles(obj)
            
            [subjects, rawFilesPath] = obj.addReviewRawFiles();
            
            assert(length(subjects) == length(rawFilesPath));
            
            str = strings(1, length(subjects));
            for i = 1:length(subjects)
                
                [~, file, ext] = cellfun(@fileparts, rawFilesPath{i}, 'UniformOutput', false);
                
                str(i) = [subjects{i} ' ['  num2str(length(rawFilesPath{i})) ...
                     ' file(s)]:' newline ...
                     strjoin(strcat(file, ext), '\n') newline];
                
            end
            
           ch = char(strjoin(str, '\n'));
            
        end
        
    end
end
