classdef ReviewRawFilesParameterGetterAndSetter < handle
    
    properties (Access = private)
        
        Subjects = cell.empty();
        RawFilesPath = cell.empty();
        
    end
    
    methods (Access = private)
        
        function obj = ReviewRawFilesParameterGetterAndSetter()
        end
        
    end
    
    methods (Access = ?ControllerPipelineBuilder)
        
        function [subjects, rawFilesPath] = getParameter(obj)
            
            subjects = obj.Subjects;
            rawFilesPath = obj.RawFilesPath; 
            
        end
        
        function clearParameter(obj)
            
            obj.Subjects = cell.empty();
            obj.RawFilesPath = cell.empty();
            
        end
        
        function setParameter(obj)
           
            obj.clearParameter();
            obj.addParameter(subject, rawFilesPath);
            
        end
        
        function deleteSubject(obj, index)
            
            obj.Subjects(:, index) = [];
            obj.RawFilesPath(:, index) = [];
            
        end
        
        function addParameter(obj, subjectName, rawFilesPath)

            if ischar(rawFilesPath)
                rawFilesPath = {rawFilesPath};
            end
            
            rawFilesPath = replace(rawFilesPath, '\', '/');
            
            obj.Subjects(end+1) = subjectName;
            obj.RawFilesPath{end+1} = rawFilesPath;
                
        end
        
        function parameterAsCharacters = convertParameterToCharacters(obj)
                        
            parameterAsCharacters = char(strjoin(obj.convertParameterToString, '\n'));
        
        end
        
        function parameterAsString = convertParameterToString(obj)
            
            parameterAsString = strings(1, length(obj.Subjects));
            for i = 1:length(obj.Subjects)
                
                % Get file and extension for each files
                [~, file, ext] = cellfun(@fileparts, obj.RawFilesPath{i}, 'UniformOutput', false);
                
                parameterAsString(i) = ...
                    [obj.Subjects{i} ' ['  num2str(length(obj.RawFilesPath{i})) ...
                    ' file(s)]:' newline ...
                    strjoin(strcat(file, ext), '\n') newline];
                
            end
            
        end
        
    end
    
    methods (Static, Access = ?ControllerPipelineBuilder)
        
        function obj = instance()
           
            persistent uniqueInstance;
            
            if isempty(uniqueInstance)
                obj = ReviewRawFilesParameterGetterAndSetter();
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
            
        end
        
    end
    
end