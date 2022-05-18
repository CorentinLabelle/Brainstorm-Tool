cd('/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/scripts/AnalysisTool');

json = struct();

json.Pipeline = 'PipelineName';

json.Extension = '.json';

json.Datasets = 'allo';

json.Type = 'eeg';

json.Processes.Names = 'Notch Filter';

json.Processes.Parameters = '';

% Verification
assert(length(json.Processes.Names) == length(json.Processes.Parameters));

% Write json file
fileID = fopen('template.json', 'wt');
fprintf(fileID, jsonencode(json, 'PrettyPrint', true));
fclose(fileID);