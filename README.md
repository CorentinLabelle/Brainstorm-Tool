This repository contains all the files (2 apps and 3 scripts) necessary to run the Analysis Tool.
# Applications
## Analysis Tool

### Supported File Format
- BrainVision (.eeg, .vhdr, .vmrk)
- BioSemi (.eeg, .vhdr, .vmrk)
- NeuroLite - Coherance Software (.eeg, .vhdr, .vmrk)
- CTF MEG 275 ()


### Anatomy


## Pipeline_Builder

This side App allows the user to create, save and modify pipelines. The pipeline are saved as a MatLab structure (.mat) that can be imported in the Analysis Tool and applied on studies. The MatLab structure contains a field for every process selected. Each process field contains subfield that contains the parameter for that process.

Pipelines options:


# Scripts
## EEG_Pipeline

This script contains all the process that can be applied on an EEG study.
Input: Structure and sFiles

Functions:
- Add EEG Position
- Refine Registration
- Project Electrode on Scalp
- Detect Heartbeats
- Notch Filter
- Band Pass Filter
- Power Spectrum Density
- Average Reference
- ICA
## MEG_Pipeline

This script contains all the process that can be applied on an MEG study.
Input: Structure and sFiles

Functions:

- Convert Epoch To Continue
- Notch Filter
- Band Pass Filter
- Power Spectrum Density
- Detect Artifact
- Remove Simultaneous Events
- SSP
- ICA
- 
## Utility_Pipeline

This script contains all the process needed to run the basic operations for the Analysis Tool.
Input: Structure

Functions:
