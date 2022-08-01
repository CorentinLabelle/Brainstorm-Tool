classdef ControllerPipelineBuilder < Controller
    
    properties (SetAccess = private, GetAccess = ?Pipeline_Builder)
        
        BidsSearchPath;
        
    end
    
    methods (Access = public)
        
        function obj = ControllerPipelineBuilder()
            
        end
        
        function addProcess(obj, name, structure)
            
            process = obj.createProcess(name, structure);
            obj.CurrentPipeline.addProcess(process);
            
        end
        
        function setPipelineFolder(obj, folder)
           
            obj.CurrentPipeline.setFolder(folder);
            
        end
        
        function setPipelineName(obj, name)
           
            obj.CurrentPipeline.setName(name);
            
        end
        
        function setPipelineExtension(obj, extension)
           
            obj.CurrentPipeline.setExtension(extension);
            
        end
        
        function setPipelineType(obj, type)
           
            obj.CurrentPipeline.setType(type);
            
        end
        
        function savePipeline(obj)
            
            obj.CurrentPipeline.save();
            
        end
        
        function setBidsSearchPath(obj, path)
            
           obj.BidsSearchPath = path;
            
        end
        
        function path = getBidsSearchPath(obj)
            
           path = obj.BidsSearchPath;
            
        end
        
        function addSubject(~, subjectName, rawDataPath)
            
            rawFilesManager = ReviewRawFilesParameterGetterAndSetter.instance();
            rawFilesManager.addParameter(subjectName, rawDataPath);
            
        end
        
        function clearSubjects(~)
            
            rawFilesManager = ReviewRawFilesParameterGetterAndSetter.instance();
            rawFilesManager.clearParameter();
            
        end
        
        function [subjects, rawFilesPath] = getReviewRawFilesParameters(~)
            
            rawFilesManager = ReviewRawFilesParameterGetterAndSetter.instance();
            [subjects, rawFilesPath] = rawFilesManager.getParameter();
            
        end
        
        function deleteSubjectInReviewRawFilesParameters(~, index)
            
            rawFilesManager = ReviewRawFilesParameterGetterAndSetter.instance();
            rawFilesManager.deleteSubject(index);
            
        end
        
        function parametersAsCharacters = convertReviewRawFilesParametersToCharacters(~)
           
            rawFilesManager = ReviewRawFilesParameterGetterAndSetter.instance();
            parametersAsCharacters = rawFilesManager.convertParameterToCharacters();
            
        end
        
    end
    
end
