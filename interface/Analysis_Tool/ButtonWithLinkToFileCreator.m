classdef ButtonWithLinkToFileCreator < handle
    
    properties (Access = private)
        
        ButtonHeight = 20;
        
    end
    
    methods (Access = public)
        
        function createHistoryButton(obj, sFiles, panel)
            
            for i = 1:length(sFiles)
                
                pathToFile = fullfile(pwd, strcat(sFiles(i).Condition, '_provenance.json'));
                fileCreator = BidsFileCreator();
                fileCreator.createProvenanceFile(sFiles(i), pathToFile);
                
                studyName = sFiles(i).FileName;
                obj.createButton(studyName, pathToFile, panel);
                 
            end
            
        end
        
        function createEventButton(obj, sFiles, panel)
                        
            for i = 1:length(sFiles)
                
                pathToFile = fullfile(pwd, strcat(sFiles(i).Condition, '_event_meta_data.json'));
                fileCreator = BidsFileCreator();
                fileCreator.createEventMetaDataFile(sFiles(i), pathToFile);
                
                studyName = sFiles(i).FileName;
                obj.createButton(studyName, pathToFile, panel);
                 
            end
            
        end
        
        function createPipelineReportButton(obj, pathToFile, panel)
            
            [~, filename] = fileparts(pathToFile);
            
            button = uibutton(panel, ...
                'ButtonPushedFcn', @(button,event) obj.openFile(button, pathToFile), ...
                'Text', filename);
            
            button.Position = obj.getPosition(panel);
            
        end
        
        function createButton(obj, buttonName, pathToFile, panel)
           
            button = uibutton(panel, ...
                'ButtonPushedFcn', @(button,event) obj.openReport(button, pathToFile), ...
                'Text', buttonName);
            
            button.Position = obj.getPosition(panel);
            
        end
        
        function position = getPosition(obj, panel)
           
            panelChildren = panel.Children;
            nbChildren = length(panelChildren);
            
            positionPanel = panel.Position;
            
            position(1) = 1;
            position(2) = positionPanel(4)-(obj.ButtonHeight*(nbChildren+1));
            position(3) = positionPanel(3)-2;
            position(4) = obj.ButtonHeight;            
            
        end
        
    end
    
    methods (Access = private)
    
        function openFile(~, ~, path)
            
            open(path)
            
        end
         
        function openReport(~, ~, reportLink)
           
            bst_report('Open', reportLink);
            
        end
        
    end
    
end

