function [baseDirectory, instruction] = runDeployedAutomatedTool(jsonFile)

    [baseDirectory, instruction] = AutomatedTool.getCommandLineInstructionToRunAsDeployed(jsonFile);
    
    instructions = ['cd ' baseDirectory '; ' instruction];
    
    system(instructions);
    
end



% function [binFolder, instruction] = runDeployedAutomatedTool(jsonFile)
% 
%     arguments
%         jsonFile = char.empty();
%     end
%     
%     automatedToolPath = AutomatedTool.getFilePath();    
%     
%     binFolder = fullfile(PathsGetter.getBrainstorm3Path(), 'bin', matlabRelease.Release);
%     
%     if ~isfolder(binFolder)
%             error('The bin folder does not exist. You have to compile the tool!');
%     end
%     
%     if ispc
%         batchFile = 'brainstorm3.bat';
%         matlabRoot = '';
% 
%     elseif ismac || isunix
%         batchFile = fullfile(binFolder, 'brainstorm3.command');
%         matlabRoot = '/usr/local/MATLAB_Runtime/v98/';
%     end
% 
%     instruction = [batchFile ' ' matlabRoot ' ' automatedToolPath ' ' jsonFile];
%     
% end