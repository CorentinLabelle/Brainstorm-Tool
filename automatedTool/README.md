# Automated Tool
The automated tool is a version of the tool that can be use without a MATLAB license (using Matlab Runtime). When performing an analysis, the automated tool has one input and one output.

## Requirements
- [MATLAB Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html) (R2022a)
- [Brainstorm Tool bin](https://github.com/CorentinLabelle/Brainstorm-Tool/tree/main/bst_bin/R2022a)

## Input
The input is a path to an analysis file. An analysis file contains (1) the name of the procotol (or the project), (2) the list of datasets to be processed and (3) the path to a pipeline.

## Output
The output is a path to a json file. The file contains information about the processed datasets. The exact information included in the output file is still a work in progress.

## Example
### Analysis File
```json
{
  "Pipeline": "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/mardown_files/automatedTool/scripts/EEG_pipeline_template.json",
  "Protocol": "AutomatedToolProtocol",
  "Dataset": []
}
```

### Pipeline
```json
{
  "Folder": "/mnt/3b5a15cf-20ff-4840-8d84-ddbd428344e9/ALAB1/corentin/projects/Brainstorm_Tool/mardown_files/automatedTool/scripts",
  "Name": "EEG_pipeline_template",
  "Extension": ".json",
  "Date": "06-Dec-2022 14:27:38",
  "Processes": [
    {
      "Name": "create_subject",
      "Parameters": {
        "subject_name": [
          "subject01",
          "subject02"
        ]
      }
    },
    {
      "Name": "add_eeg_position",
      "Parameters": {
        "electrode_file": "",
        "file_format": "",
        "cap": "Colin27: BrainProducts EasyCap 128"
      }
    },
    {
      "Name": "notch_filter",
      "Parameters": {
        "frequence": [
          60,
          120,
          180
        ]
      }
    },
    {
      "Name": "band_pass_filter",
      "Parameters": {
        "frequence": [
          4,
          30
        ]
      }
    },
    {
      "Name": "ica",
      "Parameters": {
        "number_of_components": 32
      }
    },
    {
      "Name": "export_to_bids",
      "Parameters": {
        "folder": "BIDS/bids",
        "project_name": "",
        "project_id": "",
        "project_description": "",
        "participant_description": "",
        "task_description": "",
        "dataset_desc_json": [],
        "dataset_sidecar_json": []
      }
    }
  ]
}
```

