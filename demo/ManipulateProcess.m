%% Manipulation of process
clear
clc

%% Get Help
help Process

%% Creation
nf = Process.create('notch filter');
aep = Process.create('add eeg position');

%% Open web documentation
%nf.openWebDocumentation();
%aep.openWebDocumentation();

%% Set documentation
nf = nf.setDocumentation('Notch filter to remove power line frequency.');
aep = aep.setDocumentation('add eeg position with Colin27 cap.');

%% Get details
type_nf = nf.getType();
type_aep = aep.getType();
name_nf = nf.getName();
name_aep = aep.getName();
date_nf = nf.getDate();
date_aep = aep.getDate();
fct_nf = nf.getAnalyzerFct();
fct_aep = aep.getAnalyzerFct();
fname_nf = nf.getfName();
fname_aep = aep.getfName();
doc_nf = nf.getDocumentation();
doc_aep = aep.getDocumentation();

% Verification
assert(strcmpi(type_nf, 'specific'));
assert(strcmpi(type_aep, 'eeg'));
assert(strcmpi(name_nf, 'notch_filter'));
assert(strcmpi(name_aep, 'add_eeg_position'));
assert(isa(date_nf, date));
assert(isa(date_aep, date));


%% Set parameters

    % with parameter name
nf = nf.setParameter('frequence', 50);
disp(nf);

    % with parameter index
aep = aep.setParameter(1, 'someFile');
aep = aep.setParameter(2, 1);
aep = aep.setParameter(3, 1);
disp(aep);
    
%% End
endMessage;