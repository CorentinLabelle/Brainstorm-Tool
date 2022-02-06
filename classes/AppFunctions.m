classdef AppFunctions
    methods
        function obj = AppFunctions()
        end
        
        function switchAnalysisTab(~, app, trigger)
            % This function is called when the type of
            % analysis is changed. When called, we specify which component triggered the function.
            
            % Input>    [string]: The component that triggered the function
        
            switch trigger
                case "TabGroup1"
                    analysisType = app.TabGroup1.SelectedTab.Title;
                case "TabGroup2"
                    analysisType = app.TabGroup2.SelectedTab.Title;
                case "DropDown"
                    analysisType = app.TypeofanalysisDropDown.Value;
                case "EEG"
                    analysisType = "EEG";
                case "MEG"
                    analysisType = "MEG";
            end

            
            switch analysisType
                case "EEG"
                    app.TabGroup1.SelectedTab = app.EEGTabGr1;
                    app.TabGroup2.SelectedTab = app.EEGTabGr2;
                    app.AnalysisType = "EEG";
                    app.AnatomyFileFormat = "FreeSurfer-fast";

                case "MEG"
                    app.TabGroup1.SelectedTab = app.MEGTabGr1;
                    app.TabGroup2.SelectedTab = app.MEGTabGr2;
                    app.AnalysisType = "MEG";
                    app.AnatomyFileFormat = "FreeSurfer";
            end
        end

        function Infos = getCurrentInformations(~, app)
            % Create (or update if already created) a structure with the
            % current informations
            
            % Output> [structure]: Current informations
            %   fields: CurrentSubject, ProtocolInfo, Studies, Subjects
            Infos = struct();
            Infos.ProtocolInfo = bst_get('ProtocolInfo');
            Infos.Studies = bst_get('ProtocolStudies');
            Infos.Subjects =  bst_get('ProtocolSubjects');

            % Check if there is an empty field.
            index = find(structfun(@isempty, Infos), 1);
            if ~isempty(index)
                
                switch index
                case 1
                    errorMessage = "ProtocolInfo field is empty";
                case 2
                    errorMessage = "ProtocolStudies field is empty";
                case 3
                    errorMessage = "ProtocolSubjects field is empty";
                end   
                uialert(app.AnalysisToolUIFigure, errorMessage, "Error");    
            end
        end

        function updateTree(obj, app)
            % Update Informations in Tree

            Infos = obj.getCurrentInformations(app);
                
            % If the dataBase is empty, do nothing
            if isempty(Infos.Studies)
                return
            end
            
            % Delete current Tree
            app.Tree.Children.delete;

            % Create a temporary node
            temporaryNode = uitreenode(app.Tree);
            temporaryNode.Text = "Temporary Node";

            % Iterate on all Studies in Protocol
            for i = 1:length(Infos.Studies.Study)
                % Get Subject Nodes already in Tree
                subjectNodes = app.Tree.Children;
               % subjectNames = string(subjectNodes.Text);
               subjectNames = {subjectNodes.Text};

                % Get Subject Name of Study
                subjectNameChar = strsplit(Infos.Studies.Study(i).BrainStormSubject, '/');
                subjectNameString = convertCharsToStrings(subjectNameChar{1});

                % Check if Subject Name is in Subject Nodes
                index = find(contains(subjectNames,subjectNameString));
                if isempty(index)
                    % Create Subject Node in Tree
                    nodeSubject = uitreenode(app.Tree);
                    nodeSubject.Text = subjectNameString;
                else
                    % Get Subject node from Tree
                    nodeSubject = subjectNodes(index);
                end
                % Create Study Node in Subject Node
                nodeStudy = uitreenode(nodeSubject);
                nodeStudy.Text = Infos.Studies.Study(i).Name;
            end
            % Delete Temporary Node
            temporaryNode.delete
            
            expand(app.Tree, "all");
            
            obj.updateCurrentProtocol(app);
            
        end

        function updateTreeAndCheckNewStudies(obj, app)
            % Update and check the new studies.
            % date format: 01-JAN-2001
            
            oldStudies = string.empty();
            count = 0;
            
            subjects = app.Tree.Children;
            for i = 1:length(subjects)
                
                studies = subjects(i).Children;
                for j = 1:length(studies)
                    
                    count = count + 1;
                    oldStudies(count) = strcat(subjects(i).Text, '-', studies(j).Text);
                end
            end

            obj.updateTree(app);

            NodetoCheck = matlab.ui.container.TreeNode.empty();
            nbNodeToCheck = 0;  
            
            subjects = app.Tree.Children;
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
            app.Tree.CheckedNodes = NodetoCheck;         
        end
        
        function sFiles = selectedStudies(~, app)
            % Create (or update if already created) a cell containing the
            % current studies that are checked in the tree.
            
            % Output> [cell]: Paths to Raw Files (subject/study/data_0study...) that were copied in the Protocol Folder

            % Get all Checked Nodes
            studiesChecked = app.Tree.CheckedNodes;
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
                    sFile = app.BasicFct.selectFiles(subjectName, condition);
                end
                j = j + 1;
                sFiles(j:j+(length(sFile)-1)) = sFile;
            end
            
             % Throw error if sFiles is empty
             if isequaln(sFiles, emptyStruct)
                 uialert(app.AnalysisToolUIFigure, 'There no study selected, this might cause an error!',...
                        'Error');
                 uiwait(gcbf)
                 return
             end 
            
             if length(unique({sFiles.FileType})) ~= 1
                 uialert(app.AnalysisToolUIFigure, 'Select only one type of file', 'Error');
                 uiwait(gcbf);
             end
        end
        
        function updateCurrentProtocol(obj, app)
            % Update the Current Protocol and Current Subject values in the text boxes.
        
            Infos = obj.getCurrentInformations(app);
        
            app.CurrentProtocolEditField.Value = Infos.ProtocolInfo.Comment;
        
            app.ProtocolPath = fullfile('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/rg/bs_db/', Infos.ProtocolInfo.Comment, '/');
        
        end 

        function selectAllStudies(~, app)
            
            % Select or Deselect all the studies in the tree.
     
            if isempty(app.Tree.CheckedNodes)
                app.Tree.CheckedNodes = app.Tree.Children;
            else
                app.Tree.CheckedNodes = [];
            end
 
        end

        function [path, extensionOut] = getFilePath(~, app, title, extensionIn, startingFolder)
            
            % If extension variable not given
            if ~exist('extensionIn','var')
                extensionIn = {'*'};
            end
            
            if ~exist('startingFolder','var')
                startingFolder = pwd;
            end
            
            % File Manager                    
            [fileName, folderPath] = uigetfile(extensionIn, title, startingFolder, ...
                'MultiSelect', 'on');
           
            % Stop if no file is selected
            if isequal(fileName, 0)
                    uialert(app.AnalysisToolUIFigure, 'No file has been selected!', 'Error');
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
        
        function rawFilesPath = EEGReviewRawFiles(obj, app, subjectName)
            
            % File Manager Interface
            title = "Select your EEG data file";
            extensionIn = {'*.eeg'; '*.bin'};       % Extensions supported
            
            [rawFilesPath, extension] = obj.getFilePath(app, title, extensionIn, app.RawDataPath);
            
            % Building Raw Data path
            pathSplit = split(rawFilesPath, '/');
            app.RawDataPath = "/" + fullfile(pathSplit{1:end-1});
                      
            % Modify file format based on extension
            switch extension
                case '.bin'
                    fileFormat = 'EEG-DELTAMED';
                    
                case '.eeg'          
                    % Data Colected with Brainvision
                    fileFormat = 'EEG-BRAINAMP';
                    
                otherwise 
                    return
            end 
            
            % Review Raw Files
            sFiles = app.BasicFct.reviewRawFiles(subjectName, rawFilesPath, fileFormat, 0);
            
            % Get .vmrk file and extract recording date
            recordingDate = obj.getDateFromVMRK(app, rawFilesPath, extension);
                
            % Modify Date of new Study in brainstormstudy.mat
            obj.modifyBrainstormStudyMATDate(app, sFiles, recordingDate);
                
        end
        
        function rawFilesPath = MEGReviewRawFiles(~, app, subjectName)
            
            % Select Data or Noise file
            choice = ["Data Files", "Noise Files", "Cancel"];
            type = uiconfirm(app.AnalysisToolUIFigure, 'Wich type of file do you want to import ?', 'Files to import', 'Options', choice);
            switch type
                case choice(1)
                title = "Select the folder containing your data files";
                ChannelAlign = 1;
            case choice(2)
                title = "Select the folder containing your noise files";
                ChannelAlign = 0;
            case choice(3)
                return
            end
            
            % Select Dataset 
            folder = uigetdir(app.WorkingFolderPath, title);      
            
            if isequal(folder, 0)
                return
            end
            
            % If only one dataset (folder) selected
            if (folder(end-2:end) == ".ds")
                rawFilesPath = folder;
            
            % If the folder selected contains multiple dataset
            else
                % Keep only data files (.ds)
                FilesName = dir([folder filesep '*.' 'ds']);
            
                % Saving FileNames in a cell (Path)
                rawFilesPath = cell(1, length(FilesName));
                
                for i=1:length(rawFilesPath)
                    rawFilesPath{i} = fullfile(FilesName(i).folder, FilesName(i).name);
                end
            end
            
            % Review Raw Files
            fileFormat = 'CTF';
            app.BasicFct.reviewRawFiles(subjectName, rawFilesPath, fileFormat, ChannelAlign);
            
            waitfor(msgbox('Note: We do not need to extract date from original files. It is done automatically'));
            
        end
        
        function allEvents = getEvents(~, app, sFiles)
            % Extract all events for every study in cFiles (sEvents).
            
            % Input>    cFiles [struc]

            % Output>   allEvents [cell]: Cell with all events that are
            %                               in at least one study.

            allEvents = cell(1, 1);
            compt = 1;
            
            % Loop through all studies
            for i = 1:length(sFiles)
                studyFile = load(fullfile(app.ProtocolPath, 'data', sFiles(i).FileName));
                eventsStruct = studyFile.F.events;
    
                % Loop through all events
                for j = 1:length(eventsStruct)
                    
                    % If event not already in allEvent cell
                    if ~any(strcmp(allEvents, eventsStruct(j).label))
                        allEvents{compt} = eventsStruct(j).label;
                        compt = compt + 1;
                    end
                end
            end
        end

        function createHistoryEventButton(obj, app, sFiles, type)
 
            % Folder to save the file
            folder = app.WorkingFolderPath;

            for i = 1:length(sFiles)
                 % Create Hyperlink
                 if type == "history"
                    pathToFile = obj.createProvenanceFile(app, sFiles(i), folder);
                    panel = app.HISTORYPanel;
                    
                 elseif type == "event"
                    pathToFile = obj.createJsonEventFile(app, sFiles(i), folder);
                    panel = app.EVENTSPanel;
                    
                 end
                 panelChildren = panel.Children;
                 studyName = sFiles(i).FileName;
                 link = pathToFile;
                 
                 % Create Button
                 button = uibutton(panel, 'ButtonPushedFcn', @(button,event) app.openFileWithButtonPushed(button, link), 'Text', studyName);

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
  
        function EEGConvertToBIDS(~, app, sFiles, BIDSpath)
            
            % Create folder
            mkdir(BIDSpath);
                    
            for i = 1:length(sFiles)
                        
                % Export study to EDF
                exportToEDF(app, sFile, app.WorkingFolderPath);
                
                %Reimport EDF file in Brainstorm 
                        % (it creates a new study that will later be deleted)       
                sFilesEDF = app.BasicFct.reviewRawFiles(sFiles(i).SubjectName, ...
                    edfFilePath, 'EEG-EDF', 0);

                % Modify date in new brainstormstudy.mat
                app.modifyBrainstormStudyMATDate(sFilesEDF, date);
        
                % Convert EDF study to BIDS
                app.EegFct.convertToBids(sFilesEDF, BIDSpath);
        
                % Get Path for TSV, JSON and PROVENANCE files.
                [TSVpath, JSONpath, PROVpath, ELECTRODEpath] = app.getBIDSpath(sFiles(i), ...
                    BIDSpath);
        
                % Create .tsv file (Events)
                app.createTsvFile(sFiles(i), TSVpath);
        
                % Create Json event description file
                app.createJsonEventFile(sFiles(i), JSONpath);
        
                % Create provenance file
                app.createProvenanceFile(sFiles(i), PROVpath);
        
                % Create electrode file
                app.createTsvElectrodeFile(sFiles(i), ELECTRODEpath);
        
                % Delete EDF study that was 're-imported'.
                bst_process('CallProcess', 'process_delete', sFilesEDF, [], ...
                'target', 2); % 1: fichier 2: folder 3: subjects
            end
        end
        
        function MEGConvertToBIDS(~, app, sFiles, BIDSpath)
    
            % Iterate for every Study
            for i = 1:length(sFiles)
            
                % Convert to BIDS
                app.BasicFct.convertToBids(sFiles(i), BIDSpath);
            
                % Get Path for TSV, JSON and PROVENANCE files.
                [TSVpath, JSONpath, PROVpath, EDFpath]  = app.getBIDSpath(sFiles(i), BIDSpath);

                % Create .edf file
                app.exportToEDF(sFiles(i), EDFpath);
                
                % Create .tsv file (Events)
                app.createTsvFile(sFiles(i), TSVpath);
                                
                % Create Json event description file
                app.createJsonEventFile(sFiles(i), JSONpath);
                
                % Create provenance file
                app.createProvenanceFile(sFiles(i), PROVpath);     

            end
            
            uiconfirm(app.AnalysisToolUIFigure, 'BIDS created!', 'Files created');
            app.updateTree;
        end

        function [TSVpath, JSONpath, PROVpath, EDFpath, ELECTRODEpath] = getBIDSpath(~, app, ...
                sFiles, BIDSpath)
               
            % Get date of study and convert (01-JAN-2001 to 20010101)
            date = app.getDateFromBrainstormStudyMAT(sFiles);
            dateSplit = split(date, '-');
            dateContracted = strcat(dateSplit{3}, app.monthConversionStrNum(dateSplit{2}), dateSplit{1});
            
            % Get the number of subject folder (/sub-000X/)
            contentOfBIDSFolder = dir(BIDSpath);
            count = 0;
            for j = 1:length(contentOfBIDSFolder)
            
                if contains(contentOfBIDSFolder(j).name, 'sub-')
                    strSplit = split(contentOfBIDSFolder(j).name, '-');
                    strNum = strSplit{2};
                    strSubNumber = str2double(strNum);
                
                    if strSubNumber > count
                        count = strSubNumber;
                    end
                end
            end
            
            
            % Build Each Path
            TSVpath = fullfile(BIDSpath, strcat('sub-', sprintf('%04d', count)), strcat('ses-', dateContracted), lower(app.AnalysisType), '/');
            JSONpath = fullfile(BIDSpath, strcat('sub-', sprintf('%04d', count)), strcat('ses-', dateContracted), lower(app.AnalysisType), '/');
            PROVpath = fullfile(BIDSpath, strcat('sub-', sprintf('%04d', count)), strcat('ses-', dateContracted), lower(app.AnalysisType), '/');
            EDFpath = fullfile(BIDSpath, strcat('sub-', sprintf('%04d', count)), strcat('ses-', dateContracted), lower(app.AnalysisType), '/');
            ELECTRODEpath = fullfile(BIDSpath, strcat('sub-', sprintf('%04d', count)), strcat('ses-', dateContracted), lower(app.AnalysisType), '/');
            
        end

        function edfFile = exportToEDF(obj, app, sFile, destination)
            % Convert brut datas in EDF file format and saves it in BIDS
            % folder
            
            % Input>    sFile [cell]
            %           destination [char]: path indicating where to save EDF file
            
            assert(length(sFile) == 1, 'Length of sFiles is not equal to one!');
            
            studyName = sFile.Condition;
            channelFile = fullfile(app.ProtocolPath, 'data', sFile.ChannelFile);
            
            dest = convertStringsToChars(fullfile(destination, strcat(studyName, '.edf')));
            
            [edfFile] = export_data(sFile.FileName, channelFile, dest, []);
            date = obj.getDateFromBrainstormStudyMAT(app, sFile);
            obj.modifyEDFDate(app, edfFile, date);
        end
        
        function pathToFile = createTsvFile(~, app, sFile, destination)
            % Create TSV file that lists the events with time and duration.
            
            % Input>    cFiles [cell]
            %           destination [char]: path indicating where to save the TSV file 
            
            
             % By default, file saved in Working Folder
            if ~exist('destination','var')
                destination = app.WorkingFolderPath;
            end
            
            % Load Event structure
            studyName = sFile.Condition;
            studyMatFile = sFile.FileName;
            studyMATfile = load(fullfile(app.ProtocolPath, 'data', studyMatFile));
            eventStruct = studyMATfile.F.events;
            
            % Initialiaze tsvFile
            tsvFile = strings([1,3]);
            count = 1;
            tsvFile(count,:) = ["onset" "duration" "trial type"];
            count = count + 1;
        
            % Loop through all event types
            for j = 1:length(eventStruct)
        
                % Loop through all time (each occurence of an event)
                for k = 1:length(eventStruct(j).times)
        
                    tsvFile(count,:) = [eventStruct(j).times(k) 0 string((eventStruct(j).label))];
                    count = count + 1;
                end
            end
            
            pathToFile = fullfile(destination, strcat(studyName, '_Events.txt'));
            
            % Write file to .txt file
            writematrix(tsvFile, pathToFile, 'Delimiter', 'tab');
  
        end
  
        function pathToFile = createTsvElectrodeFile(~, app, sFile, destination)
            
            if ~exist('destination','var')
                destination = app.WorkingFolderPath;
            end
            
            % Load Channel File
            studyName = sFile.Condition;
            channelFilePath = sFile.ChannelFile;
            channelFile = load(fullfile(app.ProtocolPath, 'data', channelFilePath));
            allChannels = channelFile.Channel;
            
            tsvElectrodeFile = strings([1,4]);
            count = 1;
            tsvElectrodeFile(count,:) = ["Name" "X coordinate" "Y coordinate" "Z coordinate"];
            count = count + 1;
                
            for i = 1:length(allChannels)
                location = allChannels(i).Loc;
                tsvElectrodeFile(count,:) = [allChannels(i).Name, string(location(1)), ...
                    string(location(2)), string(location(3))];
                count = count + 1;
            end
            
            pathToFile = fullfile(destination, strcat(studyName, '_Events.txt'));
            
            % Write file to .txt file
            writematrix(tsvElectrodeFile, pathToFile, 'Delimiter', 'tab');
            
        end
        
        function pathToFile = createProvenanceFile(~, app, sFile, destination)
            % Create Json file containing information about the study
            % (history of all functions ran on it)
            
            % Input>    cFiles [cell]
            %           destination [char]: path to save JSON file
            
            
            % By default, file saved in Working Folder
            if ~exist('destination','var')
                destination = app.WorkingFolderPath;
            end

            % Load study.mat file
            studyName = sFile.Condition;
            studyMatFile = sFile.FileName;
            studyMat = load(fullfile(app.ProtocolPath, 'data', studyMatFile));
            
            % Iterate on all event
            for j = 1:height(studyMat.History)
                activity = struct();
                activity.id = studyMat.History{j,2};
                activity.label = studyMat.History{j,3};
                activity.command = 'button pushed';
                activity.startedAtTime = studyMat.History{j,1}; 
               
                provenance.(strcat('ActivityNo', num2str(j))) = activity; 
            end
            
            % Build Provenance File Name
            fileName = strcat(studyName, '_Provenance.json');
        
            % Save as JSON file
            app.saveAsJSON(provenance, fileName)                
            
            % Cannot add path in 'saveAsJSON' arguments. Save by
            % default in current directory. If current directory is not
            % the destination, then copy/paste and delete.
            if string(destination) ~= string(pwd)
                copyfile(fileName, destination);
                delete(fileName);
            end
            
            % Return File Path
            pathToFile = fullfile(destination, fileName);
        end
        
        function pathToFile = createJsonEventFile(obj, app, sFile, destination)
            % Create JSON file that describes every event.
            
            % Input>    cFiles [cell]
            %           destination [char]: path indicating where to save the JSON file 

            % By default, file saved in Working Folder
            if ~exist('destination','var')
                destination = app.AppFolderPath;
            end
            
            % Load list of all events
            allEvents = obj.getEvents(app, sFile);

            for j = 1:length(allEvents)
                new_event = strrep(allEvents{j}, '-', '_');
                new_event = strrep(new_event, ' ', '_');
                checkFirstChar = isstrprop(new_event, 'digit');
                
                % If first character is a digit
                if (checkFirstChar(1))
                    new_event = "f" + new_event;
                end
                
                s__.(new_event) = 'Description';
            end

            s_.LongName = 'Event category';
            s_.Description = 'Indicator of type of action that is expected';
            s_.Levels = s__;

            s.trial_type = s_;

            % Build Json event Name of file
            studyName = sFile.Condition;
            fileName = strcat(studyName, '_Event_Metadata.json');
            
            % Save as Json
            app.saveAsJSON(s, fileName)
            
            % Copy the json file in a new destination and delete the old one
            if string(destination) ~= string(pwd)
                copyfile(fileName, destination);
                delete(fileName);
            end
            
            % Return File Path
            pathToFile = fullfile(destination, fileName);
        end
        
        function date = getDateFromBrainstormStudyMAT(~, app, sFiles)
            % Date format: 01-JAN-2001
            
            date = cell(1, length(sFiles));
            for i = 1:length(sFiles)
                brainstormStudyFile = app.getBrainstormStudyPathFromSFile(sFiles(i));
    
                bsStudy = load(fullfile(app.ProtocolPath, 'data', brainstormStudyFile));
                date{i} = upper(bsStudy.DateOfStudy);
            end
            
            return
        end
        
        function modifyBrainstormStudyMATDate(~, app, sFiles, date)
            % Date format: 01-JAN-2001

            for i = 1:length(sFiles)
                brainstormStudyFile = fullfile(app.ProtocolPath, 'data', app.getBrainstormStudyPathFromSFile(sFiles(i)));
                bsStudy = load(brainstormStudyFile);
                bsStudy.DateOfStudy = upper(date{i});
                save(brainstormStudyFile, '-struct', 'bsStudy');
            end
 
        end

        function newDate = getDateFromVMRK(~, app, rawFilesPath, extension)
            % Input must be raw file path of type .eeg with a corresponding
            % .vmrk file.

            newDate = cell(1,length(rawFilesPath));
            for i = 1:length(rawFilesPath)
            
                vmrkFilePath = strcat(rawFilesPath{i}(1:end-length(extension)), '.vmrk');
                
                fileid = fopen(vmrkFilePath, 'r');
                for j = 0:10  
                    fgetl(fileid);
                end
                
                textline = fgetl(fileid);

                startDate = 24;
                year = textline(startDate:startDate+3);
                month = textline(startDate+4:startDate+5);
                day = textline(startDate+6:startDate+7);
                hour = textline(startDate+8:startDate+9);
                minute = textline(startDate+10:startDate+11);
                second = textline(startDate+12:startDate+13);
                strMonth = app.monthConversionStrNum(month);
            
                newDate{i} = strcat(day, '-', strMonth, '-', year, '-', hour, '-', minute, '-', second);
                fclose(fileid);
            end
            return
        end
    
        function modifyEDFDate(~, app, edfFilePath, dateIn)
            %date format: 01-JAN-2001-14-12-12

            date = split(dateIn, '-');
            days = date{1};
            strMonth = date{2};
            
            month = app.monthConversionStrNum(strMonth);
            
            year = date{3};
            hours = date{4};
            minutes = date{5};
            secondes = date{6};
        
            % Copy files TXT file
            newFileName = strcat(edfFilePath(1:end-4), '_edf.txt');
            copyfile(edfFilePath, newFileName)
            
            % Extract line with wrong date from EDF file and replace date (at 2 places) with correct
            % date
            fileid = fopen(newFileName, 'r');
            textline = fgetl(fileid);
            index = strfind(textline, 'Startdate');
            
            % First replacement
            newline = strrep(textline, textline(index+10:index+10+10), strcat(days, '-', strMonth, '-', year));
                
            % Second replacement
            newline = strrep(newline, textline(169:184), strcat(days, '.', month, '.', year(3:4), ...
                                                    hours, '.', minutes, '.', secondes));
            fclose(fileid);
            
            fileid = fopen(newFileName, 'r+');
            fprintf(fileid, '%c', newline);
            fclose(fileid);
            
            copyfile(newFileName, edfFilePath)
            delete(newFileName);

            return
        end
        
        function checkIfChannelIsInChannelFile(~, app, sFiles, channelName)
            for i = 1:length(sFiles)
                channelFile = load(fullfile(app.ProtocolPath, 'data', sFiles(i).ChannelFile));
                if ~any(strcmp(channelName, {channelFile.Channel.Name}))
                    uialert(app.AnalysisToolUIFigure, strcat('The study ', {' '}, sFiles.Condition, ...
                        ' does not contain the channel ', {' '}, channelName), 'Error');
                end
            end
        end
        
        function ask_user(~, app, question)
            if ~app.Testing
                window = TextInput(app, question);
                waitfor(window);
            end
        end
        
        function ask_user_list(~, app, choice, question, multiselect)
            if ~app.Testing
                window = ListInput(app, choice, question, multiselect);
                waitfor(window);
            end
        end
    
        function activateTest(~, app)
            app.Testing = true;
            return
        end
        
        function switchColorModeForParent(obj, app, uiObj, backColor, textColor, textColorHyperLink)
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
                    obj.switchColorModeForParent(app, children(i), backColor, textColor, textColorHyperLink);
                end
                
            catch ME
                if strcmp(ME.identifier, 'MATLAB:noSuchMethodOrField')
                    app.switchColorModeForChildren(uiObj, backColor, textColor, textColorHyperLink);
                else
                    throw(ME);
                end
            end
        end
        
    end
end

