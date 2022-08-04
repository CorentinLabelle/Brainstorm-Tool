function [baseDirectory, instruction] = RunDeployedAutomatedTool(jsonFile)

    [baseDirectory, instruction] = AutomatedTool.getCommandLineInstructionToRunAsDeployed(jsonFile);
    instructions = ['cd ' baseDirectory '; ' instruction];
    
    system(instructions);