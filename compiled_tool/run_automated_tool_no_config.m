function sFilesOut = run_automated_tool_no_config(json)
% RUN_AUTOMATED_TOOL_NO_CONFIG Run an analysis using the automated tool with a configuration already saved
% in the user folder (~/.config/brainstorm_tool/).
%
%   [USAGE]
%       sFilesOut = run_automated_tool_no_config(analysis_json)
%   
%   [IN]
%       [string/char] analysis_json: Path to the analysis file - Absolute or relative (starts with ./) to the analysis file.
%
%   [OUT]
%       [structure] sFilesOut: Result of the analysis.
    at = AutomatedTool();
    sFilesOut = at.run(json);