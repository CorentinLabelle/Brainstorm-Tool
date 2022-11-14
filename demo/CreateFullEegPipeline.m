function eegPipeline = CreateFullEegPipeline()    

    % Create empty pipeline;
    eegPipeline = Pipeline();
    assert(eegPipeline.isDefault());
    
    % Set pipeline Details
    eegPipeline = eegPipeline.setName('eegPipeline');
    eegPipeline = eegPipeline.setFolder(fullfile(fileparts(mfilename('fullpath')), 'pipeline'));
    eegPipeline = eegPipeline.setExtension('.json');
    eegPipeline = eegPipeline.setDocumentation('Here is additionnal information.');
    
    % Create Process and Set parameters
    cs = Process.create('create_subject');
    cs = cs.setParameter('subject_name', {'subject01', 'subject02'});
    eegPipeline = eegPipeline.addProcess(cs);
    
    rrf1 = Process.create('review_raw_files');
    subject = {'subject01', 'subject02'};
    rawfiles = {{'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b1.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b2.eeg'}, ...
                {'/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b3.eeg', ...
                '/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/data/Nico/Participant_01/Data/b4.eeg'}};
    rrf1 = rrf1.setParameter('subject', subject);
    rrf1 = rrf1.setParameter('raw_files', rawfiles);
    rrf1 = rrf1.setParameter('file_format', 2);
    eegPipeline = eegPipeline.addProcess(rrf1);

    aep = Process.create('add_eeg_position');
    aep = aep.setParameter('cap', 1);
    eegPipeline = eegPipeline.addProcess(aep);

    rr = Process.create('refine_registration');
    eegPipeline = eegPipeline.addProcess(rr);

    peos = Process.create('project_electrode_on_scalp');
    eegPipeline = eegPipeline.addProcess(peos);

    nf = Process.create('notch filter');
    nf = nf.setParameter('frequence', [60 120 180]);
    eegPipeline = eegPipeline.addProcess(nf);

    bpf = Process.create('band pass filter');
    bpf = bpf.setParameter('frequence', [4 30]);
    eegPipeline = eegPipeline.addProcess(bpf);

    psdw = Process.create('power spectrum density');
    psdw = psdw.setParameter('window length', 4);    
    eegPipeline = eegPipeline.addProcess(psdw);

    ar = Process.create('average reference');   
    eegPipeline = eegPipeline.addProcess(ar);
    
    ica = Process.create('ica');
    ica = ica.setParameter('number of components', 32);    
    eegPipeline = eegPipeline.addProcess(ica);
    
    etb = Process.create('export to bids');
    etb = etb.setParameter('folder', fullfile(pwd, 'bids', 'bids'));
    eegPipeline = eegPipeline.addProcess(etb);