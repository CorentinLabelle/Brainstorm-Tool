classdef Utility

    properties
        
        DataBase_Path char;
        
    end
    
    methods (Access = public)
         
        function obj = Utility()
            
            obj.DataBase_Path = bst_get('BrainstormDbDir');
            
        end

        function [event_path, meta_event_path, provenance_path, electrode_path, coord_path] ...
                = getBIDSpath(~, sFiles, BIDSpath, type)
            
            % Get date of study and convert (ex.: 01-FEB-2003 to 20030201)
            %date = obj.getDateFromBrainstormStudyMAT(sFiles);
            %date = bst_get('Study', sFiles.iStudy).DateOfStudy;
            %dateSplit = split(date, '-');
            %dateContracted = strcat(dateSplit{3}, Utility.monthConversionStrNum(dateSplit{2}), dateSplit{1});
            
            %ses_folder = strcat('ses-', dateContracted);
            
            % Get the number of subject folder (/sub-000X/)
            contentOfBIDSFolder = dir(BIDSpath);
            sub_count = 0;
            for j = 1:length(contentOfBIDSFolder)
                folder = contentOfBIDSFolder(j).name;
                if contains(folder, 'sub-')
                    index = strfind(folder, 'sub-');
                    if length(index) > 1
                        index = index(end);
                    end
                    
                    sub_number = str2double(folder(index+4:index+7));

                    if sub_number > sub_count
                        sub_count = sub_number;
                    end
                end
            end
            
            assert(sub_count > 0);
            
            sub_folder = strcat('sub-', sprintf('%04d', sub_count));
            
            % Build path to Raw Study in BIDS folder
            type_folder = lower(type);
            study_name = strcat(sub_folder, '_', ses_folder, '_task-', replace(sFiles.Condition(5:end), '_', ''));
            path = fullfile(BIDSpath, sub_folder, ses_folder, type_folder, study_name);
            
            % Find run number
            contentOfBIDSFolder = dir(fullfile(BIDSpath, sub_folder, ses_folder, type_folder));
            run_count = 0;
            for j = 1:length(contentOfBIDSFolder)
            
                filename = contentOfBIDSFolder(j).name;
                if contains(filename, 'run-')
                    index = strfind(filename, 'run-');
                    if length(index) > 1
                        index = index(end);
                    end
                    
                    run_number = str2double(filename(index+4:index+5));
                    
                    if run_number > run_count
                        run_count = run_number;
                    end
                end
            end
           
            assert(run_count > 0);
            path = strcat(path, '_run-', sprintf('%02d', run_count));
            
            % Build Each Path
            event_path = strcat(path, '_events.tsv');
            meta_event_path = strcat(path, '_events.json');
            provenance_path = strcat(path, '_provenance.json');
            electrode_path = strcat(path, '_electrodes.tsv');
            coord_path = strcat(path, '_coordsystem.json');
            
        end

        function edfFile = exportToEDF(obj, sFile, destination)
            % Convert brut datas in EDF file format and saves it in BIDS
            % folder
            
            % Input>    sFile [cell]
            %           destination [char]: path indicating where to save EDF file
            
            % Pre-condition
            assert(length(sFile) == 1, 'Length of sFiles is not equal to one!');
            
            % Build path to file
            studyName = sFile.Condition;
            
            % RETIRER LE 'FULLFILE'
            channelFile = fullfile(obj.getChannelFilePath(sFile));
            
            % EDF Path and FileName
            destination = convertStringsToChars(fullfile(destination, strcat(studyName, '.edf')));
            
            % Export to EDF
            [edfFile] = export_data(sFile.FileName, channelFile, destination, []);
            
            % Modify Date in EDF file
%             date = obj.getDateFromBrainstormStudyMAT(sFile);
%             obj.modifyEDFDate(edfFile, date);
        end
        
        function path = create_Event_File(obj, sFile, path)
            % Create TSV file that lists the events with time and duration.
            
            % Input>    cFiles [cell]
            %           destination [char]: path indicating where to save the TSV file 
                        
            % Load Event structure
            studyMatFile = sFile.FileName;
            studyMATfile = load(fullfile(obj.DataBase_Path, bst_get('ProtocolInfo').Comment, 'data', studyMatFile));
            eventStruct = studyMATfile.F.events;
            
            % Initialiaze tsvFile variable with titles
            tsvFile = strings([1,3]);
            count = 1;
            tsvFile(count,:) = ["onset" "duration" "trial type"];
            count = count + 1;
        
            % Loop through every event types
            for i = 1:length(eventStruct)
        
                % Loop through all time (each occurence of an event)
                for j = 1:length(eventStruct(i).times)
        
                    tsvFile(count,:) = [eventStruct(i).times(j) 0 string((eventStruct(i).label))];
                    count = count + 1;
                end
            end
            
            % Get extension
            [folder, file, ext] = fileparts(path);
            
            if strcmp(ext, '.tsv')
                txtPath = fullfile(folder, strcat(file, '.txt'));
            end
            
            % Write file to .txt file
            writematrix(tsvFile, txtPath, 'Delimiter', 'tab');
            
            % Change extension (.txt to .tsv)
            movefile(txtPath, path);
        end
  
        function path = create_Electrode_File(obj, sFile, path)
            
            % Load Channel File
            channelFilePath = sFile.ChannelFile;
            channelFile = load(fullfile(obj.DataBase_Path, bst_get('ProtocolInfo').Comment, 'data', channelFilePath));
            
            % Initialiaze tsvElectrodeFile variable with titles
            tsvElectrodeFile = strings([1,4]);
            count = 1;
            tsvElectrodeFile(count,:) = ["Name" "X coordinate" "Y coordinate" "Z coordinate"];
            count = count + 1;
                
            % Loop through every channel
            allChannels = channelFile.Channel;
            for i = 1:length(allChannels)
                location = allChannels(i).Loc;
                tsvElectrodeFile(count,:) = [allChannels(i).Name, string(location(1)), ...
                    string(location(2)), string(location(3))];
                count = count + 1;
            end
                  
            % Get extension
            [folder, file, ext] = fileparts(path);
            
            if strcmp(ext, '.tsv')
                txtPath = fullfile(folder, strcat(file, '.txt'));
            end
            
            % Write file to .txt file
            writematrix(tsvElectrodeFile, txtPath, 'Delimiter', 'tab');
            
            % Change extension (.txt to .tsv)
            movefile(txtPath, path);
            
        end
        
        function path = create_Provenance_File(obj, sFile, path)
            % Create Json file containing information about the study
            % (history of all functions ran on it)
            
            % Input>    cFiles [cell]
            %           destination [char]: path to save JSON file

            % Load study.mat file
            studyMatFile = sFile.FileName;
            studyMat = load(fullfile(obj.DataBase_Path, bst_get('ProtocolInfo').Comment, 'data', studyMatFile));
            
            % Loop through every event
            for j = 1:height(studyMat.History)
                activity = struct();
                activity.id = studyMat.History{j,2};
                activity.label = studyMat.History{j,3};
                activity.command = 'button pushed';
                activity.startedAtTime = studyMat.History{j,1}; 
               
                provenance.(strcat('ActivityNo', num2str(j))) = activity; 
            end
                       
            % Encode and save structure to json
            fileID = fopen(path, 'wt');
            fprintf(fileID, jsonencode(provenance, 'PrettyPrint', true));
            fclose(fileID);
        end
        
        function path = create_Event_MetaData_File(obj, sFile, path, eventDescription)
            % Create JSON file that describes every event.
            
            % Input>    cFiles [cell]
            %           destination [char]: path indicating where to save the JSON file 
            
            arguments
                obj Utility
                sFile struct
                path char
                eventDescription struct = struct();
            end
            
            % Load list of all events
            allEvents = obj.getEvents(sFile);

            % Loop through every event
            for i = 1:length(allEvents)
                event = strrep(allEvents{i}, '-', '_');
                event = strrep(event, ' ', '_');
                checkFirstChar = isstrprop(event, 'digit');
                
                % If first character is a digit
                if (checkFirstChar(1))
                    event = "f" + event;
                end
                
                if isfield(eventDescription, event)
                    desc = eventDescription.(event);
                else
                    desc = 'No description Available';
                end
                s__.(event) = desc;
            end

            s_.LongName = 'Event category';
            s_.Description = 'Indicator of type of action that is expected';
            s_.Levels = s__;

            s.trial_type = s_;

            % Encode and save to json
            fileID = fopen(path, 'wt');
            fprintf(fileID, jsonencode(s, 'PrettyPrint', true));
            fclose(fileID);
            
        end
          
        function path = createCoordonateSystemFile(obj, sFile, path)
            
            channelFile = load(obj.getChannelFilePath(sFile));
            
            indexOfAddLocEntry = find(strcmp(channelFile.History(:,2), 'addloc'));
            coordSystem = 'MNIColin27'; % Default
            if ~isempty(indexOfAddLocEntry)
                if contains(channelFile.History(indexOfAddLocEntry,3), 'BrainProducts')
                    coordSystem = 'MNIColin27';
                end
            else
                waitfor(msgbox('Just so you know, you have not added the EEG Position'));
            end 
            
            CoordSys = struct();
            CoordSys.EEGCoordinateSystem = coordSystem;
            CoordSys.EEGCoordinateUnit = 'm';
            
            % Encode and save to json
            fileID = fopen(path, 'wt');
            fprintf(fileID, jsonencode(CoordSys, 'PrettyPrint', true));
            fclose(fileID);
            
        end
        
        function isRaw = checkIfsFileIsRaw(obj, sFile)
            
            % Initialize variable
            isRaw = true;
            
            % Load studyMatFile
            studyFile = load(fullfile(obj.DataBase_Path, ...
                bst_get('ProtocolInfo').Comment, 'data', sFile.FileName));
            
            % Check if raw
            if strcmp(studyFile.F.format, 'BST-BIN')
                isRaw = false;
            end
        end
        
        function sFile = getRawsFile(obj, sFile)
            
           % Check if raw 
           if obj.checkIfsFileIsRaw(sFile)
               return
               
           % If not raw, extract condition and select raw sFile
           else
              rawCondition = sFile.Condition(1:find(sFile.Condition == '_', 1, 'first')-1);
              sFile = obj.selectFiles(sFile.SubjectName, rawCondition);
           end
            
        end
        
        function sFiles = selectFiles(~, subjectName, condition)

                sFiles = bst_process('CallProcess', 'process_select_files_data', [], [], ...
                    'subjectname',   subjectName, ...
                    'condition',     condition, ...
                    'tag',           '', ...    Select file that include the tag
                    'includebad',    0, ...     1/0
                    'includeintra',  0, ...     1/0
                    'includecommon', 0);        %1/0
        end
        
        function checkIfChannelIsInChannelFile(obj, sFiles, channelToCheck)
            for i = 1:length(sFiles)
                channelFile = load(obj.get_Channel_File_Path(sFiles(i)));
                if ~any(strcmp(channelToCheck, {channelFile.Channel.Name}))
                    error(strcat('The study ', {' '}, sFiles.Condition, ...
                        ' does not contain the channel ', {' '}, channelToCheck), 'Error');
                end
            end
        end
        
        function path = getChannelFilePath(obj, sFile)
            
            path = fullfile(obj.DataBase_Path, bst_get('ProtocolInfo').Comment, ...
                    'data', sFile.ChannelFile);
        end
        
        function BrainstormStudyPath = getBrainstormStudyPathFromSFile(obj, sFile)
            
            BrainstormStudyPath = fullfile(obj.DataBase_Path, ...
                bst_get('ProtocolInfo').Comment, 'data', ...
                sFile.SubjectName, sFile.Condition, 'brainstormstudy.mat');
            
        end
    
        function new_date = getDateFromEDF(~, path)
            
            fileid = fopen(path, 'r');
            textline = fgetl(fileid);
            index = strfind(textline, 'Startdate');
            new_date = textline(index+10:index+10+10);
            fclose(fileid);
            
        end
        
        function allEvents = getEvents(obj, sFiles)
            % Extract all events for every study in cFiles (sEvents).
            % Input>    cFiles [struc]
            % Output>   allEvents [cell]: Cell with all events that are
            %                               in at least one study.

            allEvents = {};
            
            % Loop through all studies
            for i = 1:length(sFiles)
                studyFile = load(fullfile(obj.DataBase_Path, bst_get('ProtocolInfo').Comment, 'data', sFiles(i).FileName));
                eventsStruct = studyFile.F.events;
    
                % Loop through all events
                for j = 1:length(eventsStruct)
                    
                    % If event not already in allEvent cell
                    if ~any(strcmp(allEvents, eventsStruct(j).label))
                        allEvents = [allEvents eventsStruct(j).label];
                    end
                end
            end
        end

        function allProtocols = getAllProtocols(~)
            % Return cell of the protocol structure for every protocol
            % Save index of current Protocol
            originalProtocol = bst_get('iProtocol');
            
            % Get all protocols
            allProtocols = {};
            i = 1;
            while true
                
                bst_set('iProtocol', i);
                protocol = bst_get('ProtocolInfo');
                
                if isempty(protocol)
                    break
                end
                allProtocols = [allProtocols protocol.Comment];
                i = i + 1;
            end
            allProtocols = allProtocols(~cellfun('isempty', allProtocols));
            
            % Set original protocol.
            bst_set('iProtocol', originalProtocol);
            
        end
         
        function newDate = getDateFromVMRK(~, rawFilesPath)
            % Input must be raw file path of type .eeg with a corresponding
            % .vmrk file.

            newDate = cell(1,length(rawFilesPath));
            for i = 1:length(rawFilesPath)
                % Build .vmrk file to read
                [folder, file, extension] = fileparts(rawFilesPath{i});
                vmrkFilePath = strcat(fullfile(folder, file), '.vmrk');
                
                % Assert the original file is .eeg and that the .vmrk file exists
                assert(strcmp(extension, '.eeg'));
                assert(isfile(vmrkFilePath));
                
                % Open .vmrk and read date
                % Open file
                fileid = fopen(vmrkFilePath, 'r');
                
                % Skip 10 lines
                for j = 0:10  
                    fgetl(fileid);
                end
                
                % Read line
                textline = fgetl(fileid);
                
                % Close file
                fclose(fileid);

                % Extract date from extracted line
                startDate = 24;
                year = textline(startDate:startDate+3);
                month = textline(startDate+4:startDate+5);
                day = textline(startDate+6:startDate+7);
                hour = textline(startDate+8:startDate+9);
                minute = textline(startDate+10:startDate+11);
                second = textline(startDate+12:startDate+13);
                strMonth = Utility.monthConversionStrNum(month);
            
                % Build new date
                newDate{i} = strcat(day, '-', strMonth, '-', year, '-', hour, '-', minute, '-', second);
            end
        end
         
        function path = CreateEventStructureFile(obj, path, sFiles)
            % Build file text
            eventDescription = struct();
            
            % Event Description
            allEvents = obj.getEvents(sFiles);
            for i = 1:length(allEvents)
                eventDescription.(replace(allEvents{i}, ' ', '_')) = 'Enter Event Description';
            end

            % Encode and save to json
            fileID = fopen(path, 'wt');
            fprintf(fileID, jsonencode(eventDescription, 'PrettyPrint', true));
            open(path);
            waitfor(msgbox('Enter your event description and click OK. The BIDS export will the continue... :)'));            
            fclose(fileID);
            
        end
        
        function eventStructure = getEventStructureFile(~, path)
            
            % Open file
            fileID = fopen(path); 
            
            % Read file
            raw = fread(fileID, inf);
            str = char(raw'); 
            
            % Close file
            fclose(fileID);
            
            % Decode json string
            eventStructure = jsondecode(str);
                    
        end
        
        function eventStructure = EventStructure(obj, sFiles)

            eventStructure = struct.empty();
            ans1 = questdlg(['Do you already have a file with your '...
                            'event description ?']);

            switch ans1
                case 'Yes'
                    % Load Event Description structure from json file
                    [file, folder] = uigetfile({'*.json'}, pwd);
                    if isequal(file, 0)
                        return
                    end
                    eventStructure = obj.getEventStructureFile(fullfile(folder, file));
                    
                case 'No'
                    ans2 = questdlg('Do you want to create it?');
                    
                    switch ans2
                        case 'Yes'
                            % Create Event Description json file
                            folder = uigetdir();
                            if isequal(folder, 0)
                                return
                            end
                            
                            file = inputdlg('filename:');
                            if isempty(file)
                                return
                            end
                            
                            path = fullfile(folder, strcat(file{1}, '.json'));
                            eventStructure = obj.CreateEventStructureFile(path, sFiles);
                            
                        otherwise
                            return 
                    end
                    
                case 'Cancel'
                    return
            end
        end
        
        function date = getDateFromBrainstormStudyMAT(obj, sFiles)
            % Date format: 01-JAN-2001
            date = cell(1, length(sFiles));
            for i = 1:length(sFiles)
                brainstormStudyFile = obj.getBrainstormStudyPathFromSFile(sFiles(i));
                bsStudy = load(brainstormStudyFile);
                date{i} = upper(bsStudy.DateOfStudy);
            end
        end
        
        function modifyEDFDate(~, edfFilePath, dateIn)
            % dateIn format: 01-JAN-2001-14-12-12
            % Split date
            date = split(dateIn, '-')';
            
            assert(length(date) == 6);
            
            % Extract line with wrong date from EDF file and replace date (at 2 places)
            % Open file to read
            fileid = fopen(edfFilePath, 'r');
            
            % Read line and get index
            textline = fgetl(fileid);
            
            % Close file
            fclose(fileid);
            
            % Replace date
            index = strfind(textline, 'Startdate');
            
            % First replacement
            newline = strrep(textline, textline(index+10:index+10+10), ...
                strcat(date{1}, '-', date{2}, '-', date{3}));
                
            % Second replacement
            newline = strrep(newline, textline(169:184), ...
                strcat(date{1}, '.', Utility.monthConversionStrNum(date{2}), ...
                '.', date{3}(3:4), date{4}, '.', date{5}, '.', date{6}));
  
            % Replace newlines in modified file
            % Open file to write
            fileid = fopen(edfFilePath, 'r+');
            
            % Write to file
            fprintf(fileid, '%c', newline);
            
            % Close file
            fclose(fileid);
            
        end
 
        
        % To improve       
       
        function rawFilesPath = MEGReviewRawFiles(~, subjectName)
            % A REVOIR AU COMPLET
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
        
        function MEGConvertToBIDS(~, app, sFiles, BIDSpath)
                
            % A REVOIR AU COMPLET
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
            app.update_Tree;
        end

        function modifyBrainstormStudyMATDate(obj, sFiles, date)
            % Date format: 01-JAN-2001
            
            for i = 1:length(sFiles)
                brainstormStudyFile = obj.getBrainstormStudyPathFromSFile(sFiles(i));
                bsStudy = load(brainstormStudyFile);
                bsStudy.DateOfStudy = upper(date{i});
                save(brainstormStudyFile, '-struct', 'bsStudy');
                
                sStudy = bst_get('Study', sFiles(i).iStudy);
                sStudy.DateOfStudy = upper(date{i});
            end
 
        end
    

     end
    
    methods(Static)
        
        function str = formatDateToString(date)
            % Convert YYYY-MM-DD-HH-MM-SS to YYYY-MM-DD-HHh-MMm-SSs
            
            date = string(split(date, '-'))';
            
            assert(length(date) == 6);
            
            str = strcat(num2str(date(1)), '-', Utility.monthConversionStrNum(date(2)), '-', ...
                num2str(date(3)), '__', num2str(date(4)), 'h', num2str(date(5)), 'm', ...
                num2str(date(6)), 's');
        end

        function date = get_Time_Now()
            date = clock;
            date(6) = round(date(6));
            date = sprintf('%.0f-' , date);
            date = date(1:end-1); % Remove last hyphen
        end
        
        function rep = monthConversionStrNum(input)
            % Initialization
            monthsName = {'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
            monthsNum = {'01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'};
            monthStruct = cell2struct(monthsNum, monthsName, 2);     
            
            % Get month name or month number
            
            % If number
            if isnumeric(input)
                assert(input > 0 && input <= 12);
                rep = monthsName{input};

            % If char or string
            elseif ischar(input) || isstring(input)
                
                strUpper = upper(input);
                
                if isfield(monthStruct, strUpper)
                    
                    rep = monthStruct.(strUpper);
                    
                else
                    monthsNum = (str2double(input));
                    assert(monthsNum > 0 && monthsNum <= 12);
                    rep = monthsName{monthsNum};
                end

            else
                error(['The input is of the wrong class (' class(input) ').']);
                
            end
        end


        % The next function has been taken here:
        % https://www.mathworks.com/matlabcentral/fileexchange/77284-structure-and-object-to-json?s_tid=srchtitle

        % Unused ?
        function saveAsJSON(data, jsonFileName)
            % saves the values in the structure 'data' to a file in JSON format.
            % Based on the work of Lior Kirsch at: https://uk.mathworks.com/matlabcentr
            % al/fileexchange/50965-structure-to-json
            %
            % Modification by Arthur Y.C. Liu 24/06/2020
            %
            % Example:
            %     data.name = 'chair';
            %     data.color = 'pink';
            %     data.eye = eye(3);
            %     data.metrics.imageSize = [1920; 1080];
            %     data.metrics.height = 0.3;
            %     data.metrics.width = 1.3;
            %     saveJSONfile(data, 'out.json');
            %
            % Output 'out.json':
            % {
            % 	"name" : "chair",
            % 	"color" : "pink",
            % 	"eye" :
            % 	[
            % 		1,
            % 		0,
            % 		0,
            % 		0,
            % 		1,
            % 		0,
            % 		0,
            % 		0,
            % 		1
            % 	],
            % 	"metrics" :
            % 	{
            % 		"imageSize" :
            % 		[
            % 			1920,
            % 			1080
            % 		],
            % 		"height" : 0.3,
            % 		"width" : 1.3
            % 	}
            % }
            fid = fopen(jsonFileName,'w');
            if isobject(data)
                data = toStruct(data);
            end
            writeElement(fid, data, '', true);
            fprintf(fid,'\n');
            fclose(fid);


            function writeElement(fid, data, tabs, isFirstLine)
                namesOfFields = fieldnames(data);
                numFields = length(namesOfFields);
                tabs = sprintf('%s\t', tabs);
                if nargin == 4
                    if isFirstLine
                        fprintf(fid,'%s{\n%s', tabs(1:end-1), tabs);
                    end
                else
                    fprintf(fid,'\n%s{\n%s', tabs(1:end-1), tabs);
                end
                for i = 1:numFields
                    currentField = namesOfFields{i};
                    currentElementValue = data.(currentField);
                    writeSingleElement(fid, currentField, currentElementValue, tabs);
                    if i == numFields
                        fprintf(fid,'\n%s}',  tabs(1:end-1));
                    else
                        fprintf(fid,',\n%s', tabs);
                    end
                end
            end

            function writeSingleElement(fid, currentField, currentElementValue, tabs)
                % if this is an array/matrix and not a string then iterate on every
                % element, if this is a single element write it
                if ~isstruct(currentElementValue) &&...
                        length(currentElementValue) > 1 && ~ischar(currentElementValue)
                    fprintf(fid,'"%s" : \n%s[\n%s\t',currentField, tabs, tabs);
                    tabs = sprintf('%s\t', tabs);
                    valLength = length(currentElementValue(:));
                    for m = 1:valLength
                        fprintf(fid,'%g' , currentElementValue(m));
                        if m == valLength
                            fprintf(fid,'\n%s]', tabs(1:end-1));
                        else
                            fprintf(fid,',\n%s', tabs);
                        end
                    end
                elseif isstruct(currentElementValue) &&...
                        length(currentElementValue) > 1 && ~ischar(currentElementValue)
                    fprintf(fid,'"%s" : \n%s[',currentField, tabs);
                    tabs = sprintf('%s\t', tabs);
                    valLength = length(currentElementValue(:));
                    for m = 1:valLength
                        writeElement(fid, currentElementValue(m), tabs);
                        if m == valLength
                            fprintf(fid,'\n%s]', tabs(1:end-1));
                        else
                            fprintf(fid,',');
                        end
                    end
                elseif isstruct(currentElementValue)
                    fprintf(fid,'"%s" : ',currentField);
                    writeElement(fid, currentElementValue, tabs);
                elseif isnumeric(currentElementValue) || islogical(currentElementValue)
                    fprintf(fid,'"%s" : %g' , currentField, currentElementValue);
                elseif isempty(currentElementValue)
                    fprintf(fid,'"%s" : "null"' , currentField);
                elseif isobject(currentElementValue)
                    currentElementValue = toStruct(currentElementValue);
                    fprintf(fid,'"%s" : ',currentField);
                    writeElement(fid, currentElementValue, tabs);
                else %ischar or something else ...
                    fprintf(fid,'"%s" : "%s"' , currentField, currentElementValue);
                end
            end

        end
        
    end
end
    