classdef App_Manager
    
    properties
        
        App Analysis_Tool;
      
    end
      
    methods
        
        function obj = App_Manager(app)
            obj.App = app;
        end
        
        function switch_Analysis_Type(obj, analysisType)
            
            switch analysisType
                case "EEG"
                    obj.App.EEGMenu.Checked = true;
                    obj.App.MEGMenu.Checked = false;
                    obj.App.TabGroup1.SelectedTab = obj.App.EEGTabGr1;
                    obj.App.TabGroup2.SelectedTab = obj.App.EEGTabGr2;
                    obj.App.AnalysisType = "EEG";
                    obj.App.AnatomyFileFormat = "FreeSurfer-fast";

                case "MEG"
                    obj.App.EEGMenu.Checked = false;
                    obj.App.MEGMenu.Checked = true;
                    obj.App.TabGroup1.SelectedTab = obj.App.MEGTabGr1;
                    obj.App.TabGroup2.SelectedTab = obj.App.MEGTabGr2;
                    obj.App.AnalysisType = "MEG";
                    obj.App.AnatomyFileFormat = "FreeSurfer";
            end
        end

        function update_Tree(obj)
            % Update Informations in Tree

            studies = bst_get('ProtocolStudies');
            
            % Delete current Tree
            obj.App.Tree.Children.delete;

            % Create a temporary node
            temporaryNode = uitreenode(obj.App.Tree);
            temporaryNode.Text = "Temporary Node";

            % Iterate on all Studies in Protocol
            for i = 1:length(studies.Study)
                % Get Subject Nodes already in Tree
                subjectNodes = obj.App.Tree.Children;
                % subjectNames = string(subjectNodes.Text);
                subjectNames = {subjectNodes.Text};

                % Get Subject Name of Study
                subjectNameChar = strsplit(studies.Study(i).BrainStormSubject, '/');
                subjectNameString = convertCharsToStrings(subjectNameChar{1});

                % Check if Subject Name is in Subject Nodes
                index = find(contains(subjectNames,subjectNameString));
                if isempty(index)
                    % Create Subject Node in Tree
                    nodeSubject = uitreenode(obj.App.Tree);
                    nodeSubject.Text = subjectNameString;
                else
                    % Get Subject node from Tree
                    nodeSubject = subjectNodes(index);
                end
                % Create Study Node in Subject Node
                nodeStudy = uitreenode(nodeSubject);
                nodeStudy.Text = studies.Study(i).Name;
            end
            % Delete Temporary Node
            temporaryNode.delete
            
            expand(obj.App.Tree, "all");
            
            obj.update_Current_Protocol();
            
        end

        function update_Tree_And_Check_New_Studies(obj)
            % Update and check the new studies.
            % date format: 01-JAN-2001
            
            oldStudies = string.empty();
            count = 0;
            
            subjects = obj.App.Tree.Children;
            for i = 1:length(subjects)
                
                studies = subjects(i).Children;
                for j = 1:length(studies)
                    
                    count = count + 1;
                    oldStudies(count) = strcat(subjects(i).Text, '-', studies(j).Text);
                end
            end

            obj.update_Tree();

            NodetoCheck = matlab.ui.container.TreeNode.empty();
            nbNodeToCheck = 0;  
            
            subjects = obj.App.Tree.Children;
            for i = 1:length(subjects)
                
                studies = subjects(i).Children;
                for j = 1:length(studies)
                    
                    newStudy = strcat(subjects(i).Text, '-', studies(j).Text);
                    
                    if ~any(oldStudies == newStudy)
                    
                        nbNodeToCheck = nbNodeToCheck + 1;
                        NodetoCheck(nbNodeToCheck) = studies(j);
                    end
                end
            end
            if isempty(NodetoCheck)
                NodetoCheck = [];
            end
            obj.App.Tree.CheckedNodes = NodetoCheck;         
        end
        
        function sFiles = selected_Studies(obj)
            % Create (or update if already created) a cell containing the
            % current studies that are checked in the tree.
            
            % Output> [cell]: Paths to Raw Files (subject/study/data_0study...) that were copied in the Protocol Folder

            % Get all Checked Nodes
            studiesChecked = obj.App.Tree.CheckedNodes;
            emptyStruct=struct("iStudy",[],"iItem",[], "FileName",[], "FileType",[], ...
                "Comment",[], "Condition",[], "SubjectFile",[], "SubjectName",[], ...
                "DataFile",[], "ChannelFile",[], "ChannelTypes",[]);
            sFiles = emptyStruct;
            j = 0;
            for i = 1:length(studiesChecked)
                
                % Remove Subject Nodes that are checked (we keep only Study
                % Nodes)
                if class(studiesChecked(i).Parent) == "matlab.ui.container.CheckBoxTree"
                    continue
                end
                 
                % If the study is 'intra' or 'default', ignore it!
                if contains(studiesChecked(i).Text, ["intra" "default"])
                    continue;
                else
                    subjectName = studiesChecked(i).Parent.Text;
                    condition = studiesChecked(i).Text;
                    % Select Files
                    sFile = obj.App.util.selectFiles(subjectName, condition);
                end
                j = j + 1;
                sFiles(j:j+(length(sFile)-1)) = sFile;
            end
            
             % Throw error if sFiles is empty
             if isequaln(sFiles, emptyStruct)
                 uialert(obj.App.AnalysisToolUIFigure, 'There no study selected, this might cause an error!',...
                        'Error');
                 uiwait(gcbf)
                 return
             end 
            
             if length(unique({sFiles.FileType})) ~= 1
                 uialert(obj.App.AnalysisToolUIFigure, 'Select only one type of file', 'Error');
                 uiwait(gcbf);
             end
        end
        
        function update_Current_Protocol(obj)
            % Update the Current Protocol and Current Subject values in the text boxes.
        
            protocol = bst_get('ProtocolInfo').Comment;
            obj.App.CurrentProtocolEditField.Value = protocol;
        
            obj.App.ProtocolPath = fullfile('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/bs_db/', protocol, '/');
        
        end 

        function select_All_Studies(obj)
            
            % Select or Deselect all the studies in the tree.
            if isempty(obj.App.Tree.CheckedNodes)
                obj.App.Tree.CheckedNodes = obj.App.Tree.Children;
            else
                obj.App.Tree.CheckedNodes = [];
            end
 
        end

        function [path, extensionOut] = get_File_Path(obj, title, extensionIn, startingFolder)
            
            % If extension variable not given
            if ~exist('extensionIn','var')
                extensionIn = {'*'};
            end
            
            if ~exist('startingFolder','var')
                startingFolder = obj.WorkinFolderPath;
            end
            
            % File Manager                    
            [fileName, folderPath] = uigetfile(extensionIn, title, startingFolder, ...
                'MultiSelect', 'on');
           
            % Stop if no file is selected
            if isequal(fileName, 0)
                    uialert(obj.App.AnalysisToolUIFigure, 'No file has been selected!', 'Error');
                    uiwait(gcbf);
            % Convert fileName to cell if only one file is selected
            elseif class(fileName) == "char"
                fileName = {fileName};
            end
            
            % Build cell with extension for every file
            extensionOut = cell(1, length(fileName));
            for i = 1:length(fileName)
                fileNameSplit = split(fileName(i), '.');
                extensionOut{i} = fileNameSplit{end};
            end
            
            if (length(unique(extensionOut)) ~= 1)
                uialert(app.AnalysisToolUIFigure, 'Please select only one type of file', 'Error');
                uiwait(gcbf);
            else
                extensionOut = strcat('.', extensionOut{1});
            end
            
            % Build path
            path = fullfile(folderPath, fileName);
            return
        end
        
        function create_History_Event_Button(obj, sFiles, type)
 
            % Folder to save the file
            folder = obj.App.WorkingFolderPath;

            for i = 1:length(sFiles)
                 % Create Hyperlink
                 if type == "history"
                    pathToFile = obj.App.util.create_Provenance_File(sFiles(i), ...
                        fullfile(folder, strcat(sFiles(i).Condition, '_provenance.json')));
                    panel = obj.App.HISTORYPanel;
                    
                 elseif type == "event"
                    pathToFile = obj.App.util.create_Event_MetaData_File(sFiles(i), ...
                        fullfile(folder, strcat(sFiles(i).Condition, '_eventMetaData.json')));
                    panel = obj.App.EVENTSPanel;
                    
                 end
                 panelChildren = panel.Children;
                 studyName = sFiles(i).FileName;
                 link = pathToFile;
                 
                 % Create Button
                 button = uibutton(panel, 'ButtonPushedFcn', @(button,event) obj.open_File_With_Button_Pushed(button, link), 'Text', studyName);

                 % Button Size and Position
                 height = 20;
                 positionPanel = panel.Position;
                 if isempty(panelChildren)
                     position = [1 positionPanel(4)-height*2 positionPanel(3)-2 height];
                 else
                     position = panelChildren(1).Position + [0 -height 0 0];
                 end
                 button.Position = position;
            end
        end
  
        function ask_user(obj, question)
            if ~obj.App.Testing
                window = TextInput(obj.App, question);
                waitfor(window);
            end
        end
        
        function ask_user_list(obj, choice, question, multiselect)
            if ~obj.App.Testing
                window = ListInput(obj.App, choice, question, multiselect);
                waitfor(window);
            end
        end
    
        function activate_Test(obj)
            obj.App.Testing = true;
        end
        
        function switch_Parent_Color_Mode(obj, uiObj, backColor, textColor, textColorHyperLink)
            try 
                children = uiObj.Children;
                cls = class(uiObj);
                
                switch cls
                    case 'matlab.ui.Figure'
                       uiObj.Color = backColor; 
                       
                    case 'matlab.ui.container.Panel'
                        uiObj.BackgroundColor = backColor;
                        uiObj.ForegroundColor = textColor;
                           
                    case 'matlab.ui.container.CheckBoxTree'
                        uiObj.BackgroundColor = backColor;
                        uiObj.FontColor = textColor;
                           
                    case 'matlab.ui.container.TreeNode'
                        
                    case 'matlab.ui.container.TabGroup'
                        
                    case 'matlab.ui.container.Tab'
                        uiObj.BackgroundColor = backColor;
                        
                    case 'matlab.ui.container.Menu'
                        %uiObj.ForegroundColor = textColor;
                        
                end
        
                for i = 1:length(children)
                    obj.switch_Parent_Color_Mode(children(i), backColor, textColor, textColorHyperLink);
                end
                
            catch ME
                if strcmp(ME.identifier, 'MATLAB:noSuchMethodOrField')
                    obj.switch_Children_Color_Mode(uiObj, backColor, textColor, textColorHyperLink);
                else
                    throw(ME);
                end
            end
        end
        
        function switch_Children_Color_Mode(~, uiObj, backColor, textColor, textColorHyperLink)
            cls = class(uiObj);
            
            switch cls
                case 'matlab.ui.control.Button'
                    uiObj.FontColor = textColor;
                    uiObj.BackgroundColor = backColor;
        
%                 case 'matlab.ui.container.Panel'
%                     %obj.BackgroundColor = backColor;
%                     %obj.ForegroundColor = textColor;
%                     %buttonIntab = obj.Children;
%                     
                case 'matlab.ui.control.Hyperlink'
                     uiObj.VisitedColor = textColor;
                     uiObj.BackgroundColor = backColor;
                     uiObj.FontColor = textColorHyperLink;
                            
                case 'matlab.ui.control.Label'
                    uiObj.BackgroundColor = backColor;
                    uiObj.FontColor = textColor;
                    
                case 'matlab.ui.control.TextArea'
                    uiObj.FontColor = textColor;
                    uiObj.BackgroundColor = backColor;
                    
                case 'matlab.ui.control.EditField'
                    
                case 'matlab.ui.control.DropDown'
                    uiObj.FontColor = textColor;
                    uiObj.BackgroundColor = backColor;
                    
%                 case 'matlab.ui.control.CheckBoxTree'
%                     obj.FontColor = textColor;
        
            end
        end
        
        function open_File_With_Button_Pushed(~, ~, path)
            open(path)
        end
        
        function [rawFilesPath, extension] = review_Raw_Files(obj, title, extension_in)

            % User input to select file
            [rawFilesPath, extension] = obj.get_File_Path(title, extension_in, obj.App.RawDataSearchPath);
            
            % Building New Raw Data path
            delimiter = '/';
            if contains(rawFilesPath, '\')
                delimiter = '\';
            end
            pathSplit = split(rawFilesPath, delimiter);
            obj.App.RawDataSearchPath = "/" + fullfile(pathSplit{1:end-1});
            
        end
        
    end
    
end

