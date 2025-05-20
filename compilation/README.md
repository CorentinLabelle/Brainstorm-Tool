# How to compile

1. Make sure [these requirements](https://neuroimage.usc.edu/brainstorm/Tutorials/Scripting#How_to_compile_Brainstorm) are satisfied.
2. Make sure you are using [this version](https://github.com/CorentinLabelle/brainstorm3) of brainstorm.
3. Execute the function [compile_custom_brainstorm.m](./compile_custom_brainstorm.m) from Matlab. A new file (brainstorm3.jar) will be created in the folder brainstorm3/bin/R20XXa.
4. Create a folder containing
    * this repo in a 'src' folder
    * a 'bin' folder with
        * brainstorm3.bat
        * brainstorm3.command
        * brainstorm3.jar
    * the zip file of the MATLAB Runtime (MATLAB_Runtime_R2021a_Update_8_glnxa64.zip)
    * the docker file (Dockerfile)
5. Execute the create_image.sh script
    * first argument should be the path to the folder you just created
    * second argument should be the path to the container input