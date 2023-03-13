# Compiled Tool
A compiled version of the tool can be use without a MATLAB license. The compiled tool is available on Linux (will soon be available for Windows). To use the compiled version, you’ll need to:
1. Install the [Matlab Runtime R2021a](https://www.mathworks.com/products/compiler/matlab-runtime.html)
2. Download the [compiled_tool folder](./bin).

## Usage
Here is the syntax to run the tool from the terminal for Linux/MacOS (more info [here](https://neuroimage.usc.edu/brainstorm/Tutorials/Scripting#Without_Matlab)):

```brainstorm3.command <MATLABROOT> <run_automated_tool.m> <PathToAnalysisFile>```

**\<MATLABROOT>**: Path to the Matlab Runtime installation folder, e.g. ```/usr/local/MATLAB_Runtime/v98/```.

**<AutomatedToolScript.m>**: Path to the script ```run_automated_tool.m```.

**\<PathToAnalysisFile>**: Path to an [analysis file](../automated_tool/AnalyisFile.md).

When running the tool for the first time, user will be prompted to select a directory for the Data, the Pipelines and the Analysis Files. These directories will be saved in the user configuration. This will allow the user to use absolute paths or relative paths. For example, if a path to a data is relative, the tool will assume the path is relativeto the Data directory.
  
## Output
When the analysis is completed, a new JSON file with the tag ```<analysis_file>_output.json``` will be created in the same folder as the analysis file. This output file will contain the information about the modified datasets.

## Ressource Consumption
#### Tool compilation without plug-ins
Compilation lasts 3 minutes and requires about 2G of memory.
#### Tool compilation with plug-ins
Compilation lasts 15 minutes and requires about 3.5G of memory.
#### Executing the tool
The ressource consumption when executing the tool depends on the analysis. Typically, it should require about 2G of memory.

## Docker Container
A Docker Container used to run the compiled tool should contain the following:
- Linux Base Image (any Linux distribution)
- [MATLAB Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html) R2021a
- The [compiled_tool bin](./bin) folder.

## Boutique Descriptor
See the [Boutique Descriptor](./BoutiqueDescriptor.md).

## Test Files

#### Brainstorm_Tool_Hello_World.m
This script instantiates a process and a pipeline. It should print out ```Hello World```.

#### Open_Brainstorm.m
This script opens the Brainstorm interface.
