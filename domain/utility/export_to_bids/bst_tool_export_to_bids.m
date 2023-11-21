function Output = bst_tool_export_to_bids(sInputs, output_folder)

    nInputs = length(sInputs);
    Output = cell(1, nInputs);
    disp('Exporting files can take awhile');
    for iInput = 1:nInputs
        disp(['Exporting file ' num2str(iInput) ' of ' num2str(nInputs)]);
        tic
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
        derivatives = fullfile(output_folder, 'derivatives', 'bst_pipeline_output', sub, ses);
        if ~isfolder(derivatives)
            mkdir(derivatives);
        end
        
        % Export files
        Output{iInput} = export_files(sFile, sInput, derivatives);

        % Create provenance.json
        provenance_json_path = bst_fullfile(derivatives, [rawName '_provenance.json']);
        create_provenance_file(sInput, provenance_json_path);
        
        toc        
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

function provenance = create_provenance_var(sFile)
    study_mat = load(sFile_get_study_path(sFile));

    for iHistory = 1:height(study_mat.History)
        activity = struct();
        activity.id = study_mat.History{iHistory,2};
        activity.label = study_mat.History{iHistory,3};
        activity.command = 'button pushed';
        activity.startedAtTime = study_mat.History{iHistory,1}; 

        provenance.(strcat('ActivityNo', num2str(iHistory))) = activity; 
    end       
end
