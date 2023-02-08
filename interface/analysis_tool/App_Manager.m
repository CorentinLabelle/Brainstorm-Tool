classdef App_Manager
    
    properties (Access = private)
        
        App Analysis_Tool;
        %BstUtil;
        LogoFolder = fullfile('interface', 'logos');
      
    end
      
    methods (Access = public)
        
        function obj = App_Manager(app)
            
            obj.App = app;
            %obj.BstUtil = BstUtility.instance();

        end
        
        function type = askUserToSelectType(obj)
            
            choice = ["EEG", "MEG"];
            type = uiconfirm(obj.App.AnalysisToolUIFigure, ...
                "What type of analysis do you want to conduct ?", ...
                "Type of analysis", "Options", choice);
            
        end
        
        function askUserToSelectWorkingFolder(obj)
           
            wf = uigetdir(obj.App.controller.getWorkingFolderPath, ...
                    "Select your Working Folder");
            
            if isequal(wf, 0)
                uiconfirm(obj.App.AnalysisToolUIFigure, ...
                    "Default Working Folder will be : " + obj.App.controller.getWorkingFolderPath,...
                    "Default Working Folder");
            else
                wf = replace(wf, '\', '/');
                obj.App.controller.setWorkingFolderPath(wf)
            end
            
        end
        
        function frequence = askUserToSelectNotchFilterFrequence(obj)
            
            choice = [  "I am in North America (60 Hz, 120 Hz, 180 Hz, ...)", ...
                        "I am in Europe (50 Hz, 100 Hz, 150 Hz, ...)", ...
                        "Specific Frequence", ...
                        "Cancel"];
            rep = uiconfirm(obj.App.AnalysisToolUIFigure, ...
                'Where has your protocol been conducted ?', ...
                'Notch filter', 'Options', choice);
            
            switch rep
                case choice(1)
                    frequence = [60 120 180 240];
                case choice(2)
                    frequence = [50 100 150 200];
                case choice(3)
                    question = 'Enter the frequences (Hz): ';
                    frequence = obj.App.input_dialog(question);
                case choice(4)
                    return
            end
            
        end
        
        function [LowPass, HighPass] = askUserToSelectBandPassFilterFrequence(obj)
            
            question = 'Lower cut off frequency (Hz): ';
            LowPass = str2double(obj.App.input_dialog(question));

            question = 'Higher cut off frequency (Hz): ';
            HighPass = str2double(obj.App.input_dialog(question));

            if isempty(LowPass) || isempty(HighPass)
                uialert(obj.App.AnalysisToolUIFigure, ...
                    "Please enter an upper and lower frequency cutoff points.", ...
                    'Error')
                return
            end
            
        end
        
        function isNoise = askUserIfFileIsNoiseData(obj)
           
            choice = ["Data Files", "Noise Files", "Cancel"];
            type = uiconfirm(obj.App.AnalysisToolUIFigure, ...
                'Wich type of file do you want to import ?', ...
                'Files to import', 'Options', choice);

            if strcmpi(type, 'Data Files')
                isNoise = false;
            elseif strcmpi(type, 'Noise Files')
                isNoise = true;
            else
                isNoise = false;
            end
            
%             switch type
%                 case choice(1)
%                 title = "Select the folder containing your data files";
%                 ChannelAlign = 1;
%             case choice(2)
%                 title = "Select the folder containing your noise files";
%                 ChannelAlign = 0;
%             case choice(3)
%                 return
%             end
            
        end
        
        function switchAnalysisType(obj, analysisType)
            
            obj.resizeTabs(analysisType);
            obj.App.controller.switchType(analysisType);
            
            switch analysisType
                case "EEG"
                    obj.App.EEGMenu.Checked = true;
                    obj.App.MEGMenu.Checked = false;
                    obj.App.TabGroup1.SelectedTab = obj.App.EEGTabGr1;
                    obj.App.TabGroup2.SelectedTab = obj.App.EEGTabGr2;

                case "MEG"
                    obj.App.EEGMenu.Checked = false;
                    obj.App.MEGMenu.Checked = true;
                    obj.App.TabGroup1.SelectedTab = obj.App.MEGTabGr1;
                    obj.App.TabGroup2.SelectedTab = obj.App.MEGTabGr2;
            end
            
        end

        function update_Tree(obj)

            treeManager = TreeManager(obj.App.Tree);
            treeManager.updateTree();
            obj.update_Current_Protocol();
            
        end

        function update_Tree_And_Check_New_Studies(obj)
            
            treeManager = TreeManager(obj.App.Tree);
            treeManager.updateTreeAndCheckNewStudies(); 
            
        end
        
        function sFiles = selectedStudies(obj)
            
             treeManager = TreeManager(obj.App.Tree);
             sFiles = treeManager.selectedStudies();
             
             if isempty(sFiles)
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
        
            protocol = bst_get('ProtocolInfo').Comment;
            obj.App.CurrentProtocolEditField.Value = protocol;
            
        end 

        function select_All_Studies(obj)
            
            treeManager = TreeManager(obj.App.Tree);
            treeManager.selectOrDeselectAllStudies();
 
        end

        function selectRawStudies(obj)
            
            treeManager = TreeManager(obj.App.Tree);
            treeManager.selectRawStudies();

        end
        
        function selectImportedStudies(obj)
            
            treeManager = TreeManager(obj.App.Tree);
            treeManager.selectImportedStudies();
            
        end
        
        function createEventButton(obj, sFiles)
 
            buttonCreator = ButtonWithLinkToFileCreator();
            buttonCreator.createEventButton(sFiles, obj.App.EventPanel);
            
        end
        
        function createHistoryButton(obj, sFiles)
 
            buttonCreator = ButtonWithLinkToFileCreator();
            buttonCreator.createHistoryButton(sFiles, obj.App.HistoryPanel);
            
        end
        
        function createPipelineReportButton(obj, linkOfLastReport)
            
            buttonCreator = ButtonWithLinkToFileCreator();
            buttonCreator.createPipelineReportButton(linkOfLastReport, obj.App.ReportsPanel);
            
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
        
        function switchBackgroundColor(obj, backColor, textColor, textColorHyperLink)
        
            colorSwitcher = BackgroundColorSwitcher();
            colorSwitcher.setBackgroundColor(backColor);
            colorSwitcher.setTextColor(textColor); 
            colorSwitcher.setHyperlinkTextColor(textColorHyperLink);
            
            colorSwitcher.switchBackground(obj.App.AnalysisToolUIFigure);
            
        end
        
        function rawFilesPath = selectFilesToReviewRawFiles(obj)

            [fileNames, folder] = uigetfile(...
                obj.App.controller.getSupportedDatasetFormatToGetFile(), ...
                "Select your data file", ...
                obj.App.controller.getRawDataSearchPath, ...
                'MultiSelect', 'on');
            
            if ischar(fileNames)
                fileNames = {fileNames};
            end
            
            rawFilesPath = cell(1, length(fileNames));
            for i = 1:length(fileNames)
                rawFilesPath{i} = fullfile(folder, fileNames{i});
            end
            
            obj.App.controller.setRawDataSearchPath(folder);
            
        end
        
        function loadLogos(obj)
            
            obj.App.EegNetLogo.ImageSource = fullfile(obj.LogoFolder, 'EEGNet.png');
            obj.App.BrainstormLogo.ImageSource = fullfile(obj.LogoFolder, 'Brainstorm.png');
            obj.App.CervoLogo.ImageSource = fullfile(obj.LogoFolder, 'CERVO_Bright.png');
            obj.App.BrainCanadaLogo.ImageSource = fullfile(obj.LogoFolder, 'BrainCanada_Bright.png');
            obj.App.EeglabLogo.ImageSource = fullfile(obj.LogoFolder, 'EEGLab.png');
            obj.App.UlavalLogo.ImageSource = fullfile(obj.LogoFolder, 'Ulaval_Bright.png');
            
        end
        
        function resizeTabs(obj, analysisType)
            
            if strcmpi(analysisType, 'MEG')
                obj.App.TabGroup1.Position(3) = 189;
                obj.App.TabGroup2.Position(3) = 344;
            else
                obj.App.TabGroup1.Position(3) = 358;
                obj.App.TabGroup2.Position(3) = 157;
            end
            
        end
        
    end
    
end