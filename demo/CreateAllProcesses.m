%% Create all processes and assignin parameter
clear
clc

% Print all available processes
Process.printAllProcesses();

%% Create Scalar

    % GeneralProcess
    cs = Process.create('create subject');
    rrf = Process.create('review raw files');
    etb = Process.create('export to bids');
    rbt = Process.create('reject bad trials');
    ie = Process.create('import events');
    it = Process.create('import time');
    avg = Process.create('average');
    csr = Process.create('compute sources');
    dca = Process.create('detect cardiac artifact');
    dba = Process.create('detect blink artifact');
    ed = Process.create('export data');

    % SpecificProcess
    nf = Process.create('notch filter');
    bpf = Process.create('band pass filter');
    pwsd = Process.create('power spectrum density');
    doa = Process.create('detect other artifact');
    ica = Process.create('ica');

    % EegProcess
    aep = Process.create('add eeg position');
    rr = Process.create('refine registration');
    peos = Process.create('project electrode on scalp');
    ar = Process.create('average_reference');

    % MegProcess
    %cetc = Process.create('convert epochs to continue');
    %sc = Process.create('ssp cardiac');
    %sb = Process.create('ssp blink');
    %sg = Process.create('ssp generic');
    %rse = Process.create('remove simultaneaous events');
    
    
%% Create Cell

specificProcesses = Process.create({'notch filter', 'band pass filter', ...
                                    'power spectrum density', ...
                                    'detect other artifact', 'ica'});
                                
eegProcess = Process.create({   'add eeg position', 'refine registration', ...
                                'project electrode on scalp', ...
                                'average_reference'});

%% Create cell with all process (testing)
database = Database();
processNamesByClass = database.getProcessNames();
f = fields(processNamesByClass);
allProcess = cell(1, length(f));
for i = 1:length(f)
    allProcess{i} = Process.create(processNamesByClass.(f{i})');
end


%% End
disp(['Done with script ' mfilename]);