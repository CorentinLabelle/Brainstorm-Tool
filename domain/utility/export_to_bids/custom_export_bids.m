function Output = custom_export_bids(sInputs, output_folder)

    %sInputs = GetInputStruct(sInputs);
    nInputs = length(sInputs);
    Output = cell(1, nInputs);
    for iInput = 1:nInputs
        disp(['Exporting file ' num2str(iInput) ' of ' num2str(nInputs)]);
        sInput = sInputs(iInput);
        if strcmpi(sInput.FileType, 'timefreq')
            sInput = GetInputStruct(sInput.DataFile);
        end
        DataMat = in_bst_data(sInput.FileName);
        sFile = DataMat.F;
        [~, rawName] = fileparts(sFile.filename);
        
        %% Extract string
        sub = extract_string_from_filename(rawName, 'sub-');
        ses = extract_string_from_filename(rawName, 'ses-');
        
        %% Build path
        derivatives = fullfile(output_folder, 'derivatives', sub, ses);
        if ~isfolder(derivatives)
            mkdir(derivatives);
        end
        
        %% Export files
        Output{iInput} = export_files(sFile, sInput, derivatives);
        
        % Create JSON sidecar
        %jsonFile = bst_fullfile(megFolder, [newName '.json']);
        %CreateMegJson(jsonFile, metadata);

        % Create session TSV file
        %tsvFile = bst_fullfile(sessionFolder, [prefix '_scans.tsv']);
        %CreateSessionTsv(tsvFile, newPath, dateOfStudy)

        %% Create sidecars
        % Create events.json (CERVO)
        event_json_path = bst_fullfile(derivatives, [rawName '_events.json']);
        event_structure = create_event_structure(sFile);
        create_json_file(event_json_path, event_structure);    

        % Create coordsystem.json (CERVO)
        %coord_json_path = bst_fullfile(eegFolder, [rawName '_coordsystem.json']);
        %coord_structure = create_coordinate_structure(sInput, sFile);
        %create_json_file(coord_json_path, coord_structure);

        % Create provenance.json (CERVO)
        provenance_json_path = bst_fullfile(derivatives, [rawName '_provenance.json']);
        provenance_structure = create_provenance_structure(sInput);
        create_json_file(provenance_json_path, provenance_structure);

        % Create event.tsv (CERVO)
        event_tsv_path = bst_fullfile(derivatives, [rawName '_events.tsv']);
        event_tsv_string = create_events_string(sFile);
        create_tsv_file(event_tsv_path, event_tsv_string);

        % Create electrodes.tsv (CERVO)
        electrodes_tsv_path = bst_fullfile(derivatives, [rawName '_electrodes.tsv']);
        str = create_electrodes_string(sInput);
        create_tsv_file(electrodes_tsv_path, str);

        % Create channels.tsv (CERVO)   
        channel_tsv_path = bst_fullfile(derivatives, [rawName '_channels.tsv']);
        channel_tsv_string = create_channels_string(sInput, sFile);
        create_tsv_file(channel_tsv_path, channel_tsv_string);
        
    end
    
end
            
function export_file = export_files(sFile, sInput, eegFolder)
    switch sFile.device
        case 'BRAINAMP',    FileFormat = 'EEG-BRAINAMP';    rawExt='.eeg';
        case 'EDF',         FileFormat = 'EEG-EDF';         rawExt='.edf';
        case 'EEGLAB',      FileFormat = 'EEG-EEGLAB';      rawExt='.set';
        case 'BDF',         FileFormat = 'EEG-BDF';         rawExt='.bdf';
        otherwise,          FileFormat = 'EEG-BRAINAMP';    rawExt='.eeg';
    end
    [~, rawName] = fileparts(sFile.filename);
    newPath = bst_fullfile(eegFolder, [rawName, rawExt]);
    export_file = export_data(sInput.FileName, [], newPath, FileFormat);
end

function output_string = extract_string_from_filename(filename, string)
    start_position = strfind(filename, string);
    if isempty(start_position)
        output_string = '';
        return
    end
    filename = filename(start_position:end);    
    end_position = strfind(filename, '_');
    end_position = end_position(1);    
    output_string = filename(1:end_position-1);
end

function sInputs = GetInputStruct(FileNames)
    % If single filename: convert to a list
    if ischar(FileNames)
        FileNames = {FileNames};
    end
    % Output structure
    sInputs = repmat(db_template('processfile'), 1, length(FileNames));
    % Get file type for the first file
    FileType = file_gettype(FileNames{1});
    % Remove the full path
    ProtocolInfo = bst_get('ProtocolInfo');
    FileNames = cellfun(@(c)strrep(c, [ProtocolInfo.STUDIES, filesep], ''), FileNames, 'UniformOutput', 0);
    % Convert to linux-style file names
    FileNames = cellfun(@file_win2unix, FileNames, 'UniformOutput', 0);
    % Group in studies
    FilePaths = cellfun(@(c)c(1:find(c=='/',1,'last')-1), FileNames, 'UniformOutput', 0);
    [uniquePath,I,J] = unique(FilePaths);
    % Loop on studies
    for iPath = 1:length(uniquePath)
        % Get files in this group
        iGroupFiles = find(J == iPath);
        GroupFileNames = FileNames(iGroupFiles);
        % Get study for the first file
        [sStudy, iStudy] = bst_get('AnyFile', GroupFileNames{1});
        if isempty(sStudy)
            sInputs = [];
            return;
        end
        % Set information for the files in this group
        [sInputs(iGroupFiles).iStudy]      = deal(iStudy);
        [sInputs(iGroupFiles).SubjectFile] = deal(file_win2unix(sStudy.BrainStormSubject));
        % Get channel file
        sChannel = bst_get('ChannelForStudy', iStudy);
        if ~isempty(sChannel)
            [sInputs(iGroupFiles).ChannelFile]  = deal(file_win2unix(sChannel.FileName));
            [sInputs(iGroupFiles).ChannelTypes] = deal(sChannel.Modalities);
        end
        % Condition
        if ~isempty(sStudy.Condition)
            [sInputs(iGroupFiles).Condition] = deal(sStudy.Condition{1});
        end
        % Look for items in database
        switch (FileType)
            case {'data', 'spike'}
                [tmp, iDb, iList] = intersect({sStudy.Data.FileName}, GroupFileNames);
                sItems = sStudy.Data(iDb);
                if ~isempty(sItems) && strcmpi(sItems(1).DataType, 'raw')
                    InputType = 'raw';
                else
                    InputType = 'data';
                end
            case {'results', 'link'}
                [tmp, iDb, iList] = intersect({sStudy.Result.FileName}, GroupFileNames);
                sItems = sStudy.Result(iDb);
                InputType = 'results';
            case {'presults', 'pdata','ptimefreq','pmatrix'}
                [tmp, iDb, iList] = intersect({sStudy.Stat.FileName}, GroupFileNames);
                sItems = sStudy.Stat(iDb);
                InputType = FileType;
            case 'timefreq'
                [tmp, iDb, iList] = intersect({sStudy.Timefreq.FileName}, GroupFileNames);
                sItems = sStudy.Timefreq(iDb);
                InputType = 'timefreq';
            case 'matrix'
                [tmp, iDb, iList] = intersect({sStudy.Matrix.FileName}, GroupFileNames);
                sItems = sStudy.Matrix(iDb);
                InputType = 'matrix';
            case 'dipoles'
                [tmp, iDb, iList] = intersect({sStudy.Dipoles.FileName}, GroupFileNames);
                sItems = sStudy.Dipoles(iDb);
                InputType = 'dipoles';
            otherwise
                error('File format not supported.');
        end
        % Error: not all files were found
        if (length(iList) ~= length(GroupFileNames))
            disp(sprintf('BST> Warning: %d file(s) not found in database.', length(GroupFileNames) - length(iList)));
            continue;
        end
        % Fill structure
        iInputs = iGroupFiles(iList);
        iDb = num2cell(iDb);
        [sInputs(iInputs).iItem]    = deal(iDb{:});
        [sInputs(iInputs).FileType] = deal(InputType);
        [sInputs(iInputs).FileName] = deal(sItems.FileName);
        [sInputs(iInputs).Comment]  = deal(sItems.Comment);
        % Associated data file
        if isfield(sItems, 'DataFile')
            [sInputs(iInputs).DataFile] = deal(sItems.DataFile);
        end
    end
    % Remove entries that were not found in the database
    iEmpty = cellfun(@isempty, {sInputs.FileName});
    if ~isempty(iEmpty)
        sInputs(iEmpty) = [];
    end
    % No files: exit
    if isempty(sInputs)
        return;
    end
    % Get subject names
    [uniqueSubj,I,J] = unique({sInputs.SubjectFile});
    for i = 1:length(uniqueSubj)
        sSubject = bst_get('Subject', uniqueSubj{i});
        [sInputs(J==i).SubjectName] = deal(sSubject.Name);
    end
end

function create_tsv_file(file_path, string)
    writecell(cellstr(string), file_path, 'filetype', 'text', 'delimiter', '\t');
end

function create_json_file(json_path, structure)
    fid = fopen(json_path, 'wt');
    jsonText = bst_jsonencode(structure);
    fprintf(fid, strrep(jsonText, '%', '%%'));
    fclose(fid);
end

function event_structure = create_event_structure(sFile)
    EventNames = {};
    for iEvent = 1:length(sFile.events)
        event = sFile.events(iEvent).label;
        if ~any(strcmpi(event, EventNames))
            EventNames{end + 1} = event;
        end
    end        

    event_structure = struct();
    event_structure.trial_type.LongName = '';
    event_structure.trial_type.Description = '';
    for iEvent = 1:length(EventNames)
        event_name = EventNames{iEvent};
        event_name = strrep(event_name, ' ', '_');
        event_name = strrep(event_name, '-', '_');
        event_structure.trial_type.Levels.(event_name) = '';        
    end
end

function prov_structure = create_provenance_structure(sInput)
    DataMat = in_bst_data(sInput.FileName);
    history = DataMat.History;    
    prov_structure = struct();
    for iEntry = 1:size(history, 1)
        prov_structure.Activity.id = history{iEntry, 2};
        prov_structure.Activity.label = history{iEntry, 3};
        prov_structure.Activity.startedAtTime = history{iEntry, 1};
    end
end

function electrodes_string = create_electrodes_string(sInput)
    electrodes_string(1,:) = ["name" "x" "y" "z"];
    ChannelMat = in_bst_channel(sInput.ChannelFile);
    Channels = ChannelMat.Channel;
    for iChannel = 1:length(Channels)
        chan = Channels(iChannel).Name;
        location = Channels(iChannel).Loc;
        electrodes_string(iChannel+1,:) = ...
            [chan, string(location(1)), string(location(2)), string(location(3))];
    end
end

function events_string = create_events_string(sFile)
    count = 1;
    events_string(count,:) = ["onset" "duration" "trial_type"];
    count = count + 1;
    events = sFile.events;
    for iEvent = 1:length(events)
        for iTime = 1:length(events(iEvent).times)
            event_name = (events(iEvent).label);
            events_string(count,:) = [events(iEvent).times(iTime) 0 string(event_name)];
            count = count + 1;
        end
    end
end

function channels_string = create_channels_string(sInput, sFile)
    channels_string(1,:) = ["name", "type", "units", "group", "status"];
    ChannelMat = in_bst_channel(sInput.ChannelFile);
    Channels = ChannelMat.Channel;
    for iChannel = 1:length(Channels)        
        group = Channels(iChannel).Group;
        if isempty(group)
            group = "n/a";
        end
        status = "bad";
        if sFile.channelflag(iChannel)
            status = "good";
        end
        channels_string(iChannel+1,:) = ...
            [Channels(iChannel).Name, Channels(iChannel).Type, "uV", group, status];
    end
end

function coords_structure = create_coordinate_structure(sInput, sFile)
    coords_structure = struct();
    coords_structure.EEGCoordinateSystem = 'CTF';
    coords_structure.EEGCoordinateUnits = 'm';
%     coords_structure.FiducialsCoordinates.LPA = '';
%     coords_structure.FiducialsCoordinates.RPA = '';
%     coords_structure.FiducialsCoordinates.NAS = '';
%     coords_structure.FiducialsCoordinateUnit = 'mm';
end
