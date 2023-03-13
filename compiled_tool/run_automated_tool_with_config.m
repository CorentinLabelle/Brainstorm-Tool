function sFilesOut = run_automated_tool_with_config(data_path, pipeline_path, analysis_path, analysis_json)
% RUN_AUTOMATED_TOOL_WITH_CONFIG Run the analysis using the automated tool with a specific
% configuration.
%
%   [USAGE]
%       sFilesOut = run_automated_tool_with_config(data_path, pipeline_path, analysis_path, analysis_json)
%   
%   [IN]
%       [string/char] data_path: Folder that contains the data.
%       [string/char] pipeline_path: Folder that contains the pipeline.
%       [string/char] analysis_path: Folder that contains the analysis.
%       [string/char] analysis_json: Path to the analysis file - Absolute or relative (starts with ./) to the analysis file.
%
%   [OUT]
%       [structure] sFilesOut: Result of the analysis


    config = Configuration();
    config.createConfiguration(data_path, pipeline_path, analysis_path);
    sFilesOut = run_automated_tool_no_config(analysis_json);
end

