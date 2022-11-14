function RunDeployedAutomatedTool(jsonFile)
    [baseDirectory, instruction] = AutomatedTool.getCommandLineInstructionToRunAsDeployed(jsonFile);
    if ispc()
        separator = '&&';
    elseif isunix()
        separator = ';';
    end
    instructions = ['cd ' baseDirectory ' ' separator ' ' instruction];    
    system(instructions);