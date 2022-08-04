function AllProcessTester(protocolName, deleteProtocol)
    arguments 
        protocolName = 'ProtocolForTest';
        deleteProtocol = true;
    end

    %% Add Path
    % PathsAdder.addPaths();

    %% Open Brainstorm
    if ~brainstorm('status')
        brainstorm nogui
    end

    %% Variables
    subjectName = {'Harry', 'Frodo'};
    rawFiles = {...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b3.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b4.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b5.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b6.eeg'
                };

    %% Create Protocol
    while true
        if ~ProtocolManager.isProtocolCreated(protocolName)
            CreateProtocol(protocolName);
            break;
        else
            protocolName = strcat(protocolName, '_');
        end
    end

    %% Create Subject
    for i = 1:length(subjectName)
        createSubject = CreateSubject(subjectName{i});
        createSubject.run();
    end

    listOfCurrentSubject = {bst_get('ProtocolSubjects').Subject.Name};
    assert(isequal(listOfCurrentSubject, subjectName));

    %% Review Raw Files
    for i = 1:length(subjectName)
        reviewRawFiles = ReviewRawFiles(subjectName(i), rawFiles);
        reviewRawFiles.run();

        sFiles = DatabaseSearcher.searchQuery("path", "contains", subjectName{i});
        assert(length(sFiles) == length(rawFiles));
    end
    
    %% Add EEG position
    sFiles = DatabaseSearcher.selectFiles({'*'}, {'*'});

    for i = 1:length(sFiles)
        channelFile = load(GetChannelFilePath(sFiles(i)));
        assert(all(cellfun(@(x) isequal(x, [0;0;0]), {channelFile.Channel.Loc})))
    end

    addEegPosition = AddEegPosition();
    sFiles = addEegPosition.run(sFiles); 

    for i = 1:length(sFiles)
        channelFile = load(GetChannelFilePath(sFiles(i)));
        assert(any(cellfun(@(x) ~isequal(x, [0;0;0]), {channelFile.Channel.Loc})))
    end

    %% Refine Registration
    sFiles1 = DatabaseSearcher.selectFiles({'*'}, {'*'});
    refineRegistration = RefineRegistration();
    refineRegistration.run(sFiles1);

    %% Project Electrode On Scalp
    sFiles1 = DatabaseSearcher.selectFiles({'*'}, {'*'});
    projectElectrode = ProjectElectrodeOnScalp();
    projectElectrode.run(sFiles1);

    %% Notch Filter
    sFiles1 = DatabaseSearcher.searchQuery( "path", "not contains", "notch", "and", ...
                                            "path", "not contains", "band");

    notch = NotchFilter();
    notch.run(sFiles1);

    sFiles2 = DatabaseSearcher.searchQuery("path", "contains", "notch");

    assert(length(sFiles1) == length(sFiles2));

    %% Band-Pass Filter
    sFiles1 = DatabaseSearcher.searchQuery("path", "not contains", "band");

    bandPass = BandPassFilter();
    bandPass.run(sFiles1);

    sFiles2 = DatabaseSearcher.searchQuery("path", "contains", "band");

    assert(length(sFiles1) == length(sFiles2));

    %% Power Spectrum Density
    sFile = DatabaseSearcher.searchQuery(   "path", "contains", "notch", "and", ...
                                            "path", "contains", "band");
    ppsd = PowerSpectrumDensity();
    ppsd.run(sFile);

    %% ICA
    sFile = DatabaseSearcher.searchQuery(   "path", "contains", "notch", "and", ...
                                            "path", "contains", "band", "and", ...
                                            "path", "contains", "rawb1");
    ica = Ica(4);
    sFile = ica.run(sFile);

    %% Average Reference                                        
    averageReference = AverageReference();
    sFile = averageReference.run(sFile);

    %% Export To Bids
    exportToBids = ExportToBids();
    %exportToBids.run(sFile);
    
    %% Delete Protocol
    if deleteProtocol
        ProtocolManager.deleteProtocol(protocolName);
    end

    %% Validation
    disp('No error :)');