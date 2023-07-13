# Compiled Tool
A compiled version of the tool (for Linux) can be use without a MATLAB license. To use the compiled version, you’ll need to:
1. Install the [Matlab Runtime R2021a](https://www.mathworks.com/products/compiler/matlab-runtime.html)
2. Download the [compiled_tool folder](https://drive.google.com/drive/folders/1Oz53Aangv2wxjVAZOqjLc8uLDZCGTFVu?usp=drive_link).

## Usage
Here is the syntax to run the tool from the terminal (more info [here](https://neuroimage.usc.edu/brainstorm/Tutorials/Scripting#Without_Matlab)):

```bash run_bst_tool.sh <MATLABROOT> <BIDS_DIRECTORY> <PIPELINE>```

**\<MATLABROOT>**: Path to the Matlab Runtime installation directory, e.g. ```/usr/local/MATLAB_Runtime/v910/```.

**\<BIDS_DIRECTORY>**: Path to a BIDS directory.

**\<PIPELINE>**: Path to a pipeline.
  
## Output
When the analysis is completed, a new folder is created (```<BIDS_DIRECTORY>_output```). The folder contains (1) a report, (2) the ouput data in a BIDS format and (3) a copy of the brainstorm database. 

## Ressource Consumption
#### Tool compilation without plug-ins
Compilation lasts 3 minutes and requires about 2G of memory.
#### Tool compilation with plug-ins
Compilation lasts 15 minutes and requires about 3.5G of memory.
#### Executing the tool
The ressource consumption when executing the tool depends on the analysis. Typically, it should require about 2G of memory.
