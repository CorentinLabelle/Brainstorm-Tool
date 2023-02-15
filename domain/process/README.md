# Processes
Only the pre-processing steps have been implemented. Post-processing steps will come soon.
All of these processes can be included in a pipeline, although a pipeline cannot include an EEG process and a MEG process.

## List of implemented processes
### General Process
- Create Subject
- Import Anatomy
- Review Raw Files
- Split Raw Files
- Export To Bids
- Reject Bad Trials
- Import Events
- Import Time Between Event
- Import Time
- Average
- Compute Sources
- Detect Cardiac Artifact
- Detect Blink Artifact
- Export Data
- Notch Filter
- Band Pass Filter
- Power Spectrum Density
- Detect Other Artifact
- Ica

### Eeg Process
- Add Eeg Position
- Refine Registration
- Project Electrode On Scalp
- Average Reference

### Meg Process
- Convert Epochs To Continue
- Ssp Cardiac
- Ssp Blink
- Ssp Generic
- Remove Simultaneaous Events