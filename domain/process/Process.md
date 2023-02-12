# Processes
There is different categories of process. All of them can be included in a pipeline. There is only one rule; a pipeline cannot include an EEG process and a MEG process.

## General Process
A General Process is a process that is independant of dataset's type.

## Specific Process
A Specific Process is a process that has to be applied to an EEG or MEG dataset. It's behaviour depends on the dataset's type.

## EEG Process
An EEG Process is a process that can only be applied to an EEG dataset.

## MEG Process
An MEG Process is a process that can only be applied to an MEG dataset.

## List of implemented processes
### GeneralProcess
- create_subject
- import_anatomy
- review_raw_files
- split_raw_files
- export_to_bids
- reject_bad_trials
- import_events
- import_time_between_event
- import_time
- average
- compute_sources
- detect_cardiac_artifact
- detect_blink_artifact
- export_data

### EegProcess
- add_eeg_position
- refine_registration
- project_electrode_on_scalp
- average_reference

### SpecificProcess
- notch_filter
- band_pass_filter
- power_spectrum_density
- detect_other_artifact
- ica

