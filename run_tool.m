function sFilesOut = run_tool(analysis_json, data_path, pipeline_path, analysis_path)
% RUN_TOOL Run an analysis using the automated tool.
%
%   [USAGE]
%       sFilesOut = run_tool(analysis_json): See documentation of run_automated_tool_no_config.m 
%       sFilesOut = run_tool(analysis_json, data_path, pipeline_path, analysis_path): See documentation of run_automated_tool_with_config.m 
%   
%   [IN]
%       [string/char] analysis_json: Path to the analysis file - Absolute or relative (starts with ./) to the analysis file.
%       [OPTIONNAL][string/char] data_path: Path to the data folder.
%       [OPTIONNAL][string/char] pipeline_path: Path to the pipeline folder.
%       [OPTIONNAL][string/char] analysis_path: Path to the analysis folder.
%
%   [OUT]
%       [structure] sFilesOut: Result of the analysis.

arguments
    analysis_json
    data_path = '';
    pipeline_path = '';
    analysis_path = '';
end

if isempty(data_path) && isempty(pipeline_path) && isempty(analysis_path)
    at = AutomatedTool();
    sFilesOut = at.run(json, data_path, pipeline_path, analysis_path);
else
    sFilesOut = run_automated_tool_with_config(data_path, pipeline_path, analysis_path, analysis_json);
end