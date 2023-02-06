function RunDeployedAutomatedTool(jsonFile)
    instruction = AutomatedTool.getCommandLineInstructionToRunAsDeployed(jsonFile);
    disp([newline instruction newline]);
    system(instruction);