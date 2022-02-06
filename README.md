## Overview

The **EEG-MEG Analysis Tool** can be used to convert, process and analyze EEG and MEG data. The tool offers many features and allows users to:
- create subjects,
- import subject anatomy,
- import data from any [supported recording software](#supported-file-formats),
- create multiple studies and protocols,
- convert to BIDS,
- process EEG and MEG data,
- create, save, share and load custom pipelines.

The tool is written in MatLab (version R2021a) and is based heavily on the [Brainstorm](https://neuroimage.usc.edu/brainstorm/Introduction) (v3.211101) software. It is made up of two applications ([Analysis Tool](#11-analysis-tool) and [Pipeline Builder](#12-pipeline_builder)).

## 1. Applications
### 1.1 Analysis Tool

![image](https://github.com/CorentinLabelle/EEG-MEG-Analysis-Tool/blob/main/EEG_Image.PNG)
![image](https://github.com/CorentinLabelle/EEG-MEG-Analysis-Tool/blob/main/MEG_Image.PNG)

<!---
<p float="left">  
    <img src="https://user-images.githubusercontent.com/88212708/141159087-339d6ff9-8404-4e87-ad3d-972087b1b93b.PNG" width="475"/>
    <img src="https://user-images.githubusercontent.com/88212708/141159544-cc9ad06c-11aa-47fa-97d8-49318bfa2910.PNG" width="475"/>
</p>
--->

The **Analysis Tool** is the main application. It allows users to perform MEG or EEG analysis. A user can
(1) create or delete protocols, subjects and studies;
(2) import relevant anatomy (or use a default);
(3) import data;
(4) apply multiple processes on the data. 

There are two ways to perfom an analysis:

1. **_Applying each process individually:_** This method allows the user to view the data between each process. The user can also view and modify (create, rename or delete) the events or consult the history of each study.

2. **_Running a pipeline:_** From the main app, the user can import a pipeline previously created with the [Pipeline Builder](#12-pipeline_builder) and apply it to multiple studies.

The code in the main app serves the purpose of running the interface, asking the user for information, organizing files and folders, throwing errors when needed, etc.

#### Supported File Formats
Here is the list of the supported recording softwares and file formats that can be imported. We will be adding new software and file formats as we go!
- BrainVision (.eeg, .vhdr, .vmrk)
- BioSemi (.eeg, .vhdr, .vmrk)
- NeuroLite - Coherance Software (.bin, .elc)
- CTF MEG 275 (.meg4)

#### Anatomy
When creating a new subject, there is the possibility to use a default anatomy or import a specific anatomy. 

The default anatomy is a template provided by Brainstorm. Multiple templates are available (template for babies, children, young adults, adults, etc.). 

There is also the possibility to import the specific anatomy of the subject. For estimating the brain sources of the MEG/EEG signals, the anatomy of the subject must include at least three files: (1) a T1-weighted MRI volume, (2) the envelope of the cortex and (3) the surface of the head. The user will then have to mark the fiducials points (nasion, left ear, right ear, anterior commissure, posterior commissure, inter-hemispheric point).


### 1.2 Pipeline_Builder
<p float="left">
    <img src="https://user-images.githubusercontent.com/88212708/141160093-495c6247-2fd3-48f9-8f65-996f0d22fab9.PNG" width="475"/>
    <img src="https://user-images.githubusercontent.com/88212708/141160092-d03bebcb-c83f-4299-9984-1df2f7377410.PNG" width="475"/>
</p>
The **Pipeline Builder** allows the user to create, save and modify pipelines. It can be opened from the Analysis Tool. To build a pipeline, the user selects the desired processes and enters relevant information needed for each process. The pipeline is then saved as a MatLab structure (.mat) that can be imported into the Analysis Tool and applied on studies. 

#### MatLab Structure
Here is an example of a pipeline structure:
```
├── DateOfCreation
│   └── YYYY-MM-DD-HH-MM-SS
├── Folder
│   └── C:\...
├── Name
│   └── PipelineName
├── NumberOfProcesses
│   └── 4
├── Processes
│   ├── AddEEGPosition
│   │   ├── FileType
│   │   │   └── Use Default Pattern
│   │   └── Cap
│   │       └── Colin27: BrainProducts EasyCap 128
│   ├── NotchFilter
│   │   └── Frequence
│   │       └── 60, 120, 180
│   ├── BandPassFilter
│   │   ├── LowFreq
│   │   │   └── 20
│   │   └── HighFreq
│   │       └── 140
│   └── ICA
│       └── NumberOfComponents
│           └── 32
└── Type
    └── EEG 
```

## 2. Classes

### 2.1 App Functions
This class contains all the functions needed for the app to work (create files, update interface, etc.). 

### 2.2 EEG Basic Functions
This class contains all the process that can be applied on an EEG study. It is derived from the Common Basic Functions class.

#### Processes available:
- _**Add EEG Position:**_ Import the positions of the electrodes.
- _**Refine Registration:**_ Finds a better registration between the head shape defined by the electrodes and the head surface coming from the MRI. Note that this works only if have accurate head shapes (i.e. for a specific anatomy) and electrodes positions.
- _**Project Electrode on Scalp:**_ Ensures all the electrodes touch the skin surface (only for specific anatomy).
- _**Notch Filter:**_ Notch filters are adapted for removing well identified contaminations from systems oscillating at very stable frequencies.
- _**Band Pass Filter:**_ A band-pass filter is the combination of a low-pass filter and a high-pass filter, it removes all the frequencies outside of the frequency band of interest.
- _**Power Spectrum Density:**_ This process evaluates the power of the MEG/EEG signals at different frequencies, using the Welch's method.
- _**Average Reference**_ Creates a linear projector that re-references the EEG.
- _**ICA:**_ Identifies spatial topographies (components that areindependent in time) specific to an artifact and then removes them from the recordings.

### 2.3 MEG Basic Functions
This class contains all the process that can be applied on a MEG study. It is derived from the Common Basic Functions class.

#### Processes available:
- _**Convert Epoch To Continue:**_ Brainstorm automatically imports data as epoched files. This process convert epoched files to continous files.
- _**Notch Filter:**_ Notch filters are adapted for removing well identified contaminations from systems oscillating at very stable frequencies.
- _**Band Pass Filter:**_ A band-pass filter is the combination of a low-pass filter and a high-pass filter, it removes all the frequencies outside of the frequency band of interest.
- _**Power Spectrum Density:**_ This process evaluates the power of the MEG/EEG signals at different frequencies, using the Welch's method.
- _**Detect Artifact:**_ This process can be used for detecting any kind of event (heartbeat, blink or other) based on the signal power in a specific frequency band.
- _**Remove Simultaneous Events:**_ In order to clean the signal effectively (using SSP), each artifact should be defined precisely and as independently as possible from the other artifacts. This means that we should try to avoid having two different artifacts marked at the same time.
- _**SSP:**_ The general SSP objective is to identify the sensor topographies that are typical of a specific artifact, then to create spatial projectors to remove the contributions of these topographies from the recordings.
- _**ICA:**_ Identifies spatial topographies (components that are independent in time) specific to an artifact and then removes them from the recordings.

### 2.4 Common Basic Functions
This class contains all the process needed to run the basic operations that do not affect the data (import anatomy, review raw files, etc.).

#### Processes available:
- _**Import Anatomy:**_ Creates a specific (or default) anatomy for the subject.
- _**Review Raw Files:**_ Creates a link to the original EEG files.
- _**Convert to BIDS:**_ Export EEG and MEG files following the standard data organization of the Brain Imaging Data Structure (BIDS). The data files will previously be converted to .edf.
- _**Import in database:**_ Extracts events from processed files and import them in the database.

#### Conversion to BIDS
Before the conversion to BIDS, the data files are converted to .edf. When converting to BIDS, a function is run to create 4 files:
- <label>_events.tsv: List of all the occurence of an event.
- <label>_events.json: Meta data about every event.
- <label>_provenance.json: History of all the process applied on the data.
- <label>_channelCoordinates.json: Channel coordinates.

Here is the structure of a BIDS folder (based on the [BIDS specifications for Electroencephalography v1.6.0](https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/03-electroencephalography.html)):
    
```
BIDS
├── derivatives
│   └── bst_db_mapping.mat
├── sub-<label>
│   └── ses-YYYYMMDD
│       ├── anat
│       │   └── sub-<label>_ses-YYYYMMDD_T1w.nii.gz
│       ├── eeg
│       │   ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.edf
│       │   ├── sub-<label>[_ses-<label>]_task-<label>[_acq-<label>][_run-<index>]_eeg.json
│       │   ├── <label>_events.tsv
│       │   ├── <label>_events.json
│       │   ├── <label>_provenance.json
│       │   └── <label>_channelCoordinates.json
│       └── sub-<label>_ses-YYYYMMDD_scans.tsv
├── dataset_description.json
└── README
```

## Future Directions
The next objectives will be to add the processing steps for EGG and MEG data. The processing steps include:
- Import Events: Epoching for every Event occurrence (Time Window, Baseline)
- Reject Bad Trials: Remove trials with anecdotic Artifacts
- Evoked Response: Averaging by Condition or by Subject
- Time/Frequency: Time Frequency Decomposition / Morlet's Wavelength / Multitaper
- Hilbert: "Zooming on one Frequence"
- Connectivity: Phase Locking Value/ Coherence 
- Statistics:
    
We will also be working on a standalone version of this app that could easily be shared.
