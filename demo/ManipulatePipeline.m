%% Manipulation of pipeline
clear
clc

%% Get help
help Pipeline;

%% Create Pipeline

eegPip = Pipeline();
eegPip = eegPip.setName('Demo Pipeline');
eegPip = eegPip.setFolder('somePath/someFolder');
eegPip = eegPip.setExtension('.json');

% Load pipeline for example
%eegPip = CreateFullEegPipeline();

% Display pipeline
disp(eegPip);

%% Add process

    % At the end
    
    pr = Process.create('create subject');
    eegPip = eegPip.addProcess(pr);
    
        % Verification
        lastProcess = eegPip.getProcess(eegPip.getNumberOfProcess());
        assert(pr == lastProcess);
    
    pr = Process.create('review raw files');
    eegPip = eegPip.addProcess(pr);    
    
        % Verification
        lastProcess = eegPip.getProcess(eegPip.getNumberOfProcess());    
        assert(pr == lastProcess);
    
    pr = Process.create('ica');
    eegPip = eegPip.addProcess(pr);
    
        % Verification
        lastProcess = eegPip.getProcess(eegPip.getNumberOfProcess());    
        assert(pr == lastProcess);
    
    % At a specific position
    
    pr = Process.create('notch filter');
    idx = 3;
    eegPip = eegPip.addProcess(pr, idx);
    
        % Verification
        pr_ = eegPip.getProcess(idx);    
        assert(pr == pr_);
    
    pr = Process.create('band pass filter');
    idx = 4;
    eegPip = eegPip.addProcess(pr, idx);
    
        % Verification
        pr_ = eegPip.getProcess(idx);    
        assert(pr == pr_);
    
%% Add multiple processes

    % At a specific position
    
    pr = Process.create({   'add eeg position', ...
                            'refine registration', ...
                            'project_electrode_on_scalp'});
    idx = 3;
    eegPip = eegPip.addProcess(pr, idx);
    
        % Verification
        pr_ = eegPip.getProcess(idx, idx+length(pr)-1);    
        assert(isequal(pr, pr_));
    
%% Swap two processes
    idx1 = 4;
    idx2 = 5;
    p1 = eegPip.getProcess(idx1);
    p2 = eegPip.getProcess(idx2);

    eegPip = eegPip.swapProcess(idx1, idx2);

    % Verification
    p1_ = eegPip.getProcess(idx1);
    p2_ = eegPip.getProcess(idx2);
    assert(p1 == p2_);
    assert(p2 == p1_);    
    
%% Move process
    idx1 = 1;
    idx2 = 3;
    p1 = eegPip.getProcess(idx1);

    eegPip = eegPip.swapProcess(idx1, idx2);

    % Verification
    p1_ = eegPip.getProcess(idx2);
    assert(p1 == p1_);
    
%% Delete process
    idx1 = 6;
    nbProcess = eegPip.getNumberOfProcess();

    eegPip = eegPip.deleteProcess(idx1);
    
    % Verification
    nbProcess_ = eegPip.getNumberOfProcess();
    assert(nbProcess-1 == nbProcess_);    
    
%% Verify if a process is in pipeline

    % with a process (parameters must be the same)
    pr = Process.create('review raw files');
    isIn = eegPip.isProcessIn(pr);
    assert(isIn);
    
    pr = Process.create('detect cardiac artifact');
    isIn = eegPip.isProcessIn(pr);
    assert(~isIn);
    
    % with a name
    isIn = eegPip.isProcessInPipelineWithName('band pass filter');
    assert(isIn);
    
    isIn = eegPip.isProcessInPipelineWithName('ssp');
    assert(~isIn);
    
%% Search process in pipeline
    
    % with a process
    
    % with a name
    prName = 'refine registration';
    pr_ = eegPip.findProcessWithName(prName);
    assert(pr_.getName() == Process.formatProcessName(prName));
    
%% Get index of process in pipeline

    % with a process
    
    % with a name
    prName = 'add eeg position';
    index = eegPip.getProcessIndexWithName(prName);
    assert(eegPip.getProcess(index).getName() == Process.formatProcessName(prName));    

%% Get Details about pipeline

name = eegPip.getName();
folder = eegPip.getFolder();
extension = eegPip.getExtension();
type = eegPip.getType();
date = eegPip.getDate();
documentation = eegPip.getDocumentation();

path = eegPip.getPath();
jsonPath = eegPip.getPath('.json');
matPath = eegPip.getPath('.mat');

processes = eegPip.getProcess();
nbOfProcess = eegPip.getNumberOfProcess();

%% Check pipeline type

isEeg = eegPip.isEeg();
assert(isEeg);

isMeg = eegPip.isMeg();
assert(~isMeg);
    
%% End
endMessage;