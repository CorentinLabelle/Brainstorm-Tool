function eegPip = EegPipelineNoIca()
    eegPip = CreateFullEegPipeline();
    eegPip = eegPip.setName('eegPipeline_noICA');
    assert(eegPip.isProcessInPipelineWithName('ica'));
    index = eegPip.getProcessIndexWithName('ica');
    eegPip = eegPip.deleteProcess(index);
    assert(~eegPip.isProcessInPipelineWithName('ica'));