function sFilesOut = run_automated_tool(json)
% RUN_AUTOMATED_TOOL_WITH_CONFIG Run an analysis using the automated tool.
%
%   [USAGE]
%       sFilesOut = run_automated_tool(analysis_json)
%   
%   [IN]
%       [string/char] analysis_json: Path to the analysis file - Absolute or relative (starts with ./) to the analysis file.
%
%   [OUT]
%       [structure] sFilesOut: Result of the analysis.

    at = AutomatedTool();
    sFilesOut = at.run(json);