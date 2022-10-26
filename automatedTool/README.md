# Automated Brainstorm Tool
The automated tool (based on Brainstorm) is a function that can be used within the Matlab environment or using the Matlab Runtime. The function can be used to apply a pipeline to a list of datasets.

## Requirements
- [Brainstorm]
- [Runtime] R2022a (9.12)

## Note about the Brainstorm Database
The Brainstorm database contains the protocols. A protocol contains a list of subjects and, for every subject, a list of studies (datasets). Adding a dataset to a subject is done using the process _Review Raw Files_. The dataset can then be analyzed using different processes (filters, ica, etc.). Although the user can visualize the processed datasets, the processeses are not actually applied until the dataset is imported in the database.

## Boutique Descriptor
The following descriptions follows the [Boutique Descriptor Tutorial](https://nbviewer.org/github/boutiques/tutorial/blob/master/notebooks/boutiques-tutorial.ipynb#Step-3.2:-Adding-i/o-parameters).

### Input
The automated tool takes two inputs:
- [Analysis_File]: The absolute path to an [Analysis File](#analysis-file-description).
```json
{
    "id" : "analysis_file",
    "name" : "Analysis File",
    "type" : "File",
    "description" : "Absolute path to an Analysis File",
    "value-key" : "[Analysis_File]"
}
```

### Output
The automated tool has one output:
- [Output_File]: The absolute path to a JSON file which contains information about the processed datasets (see template [here](AnalysisFileTemplate_output.json)).
```json
{
    "id" : "outfile",
    "name" : "Output File",
    "description" : "Absolute path to the output file",
    "path-template" : "[Ouput_File].json"
}
```

## Analysis File description
| Keyname | Requirement Level | Data Type | Description |
|:-|:-|:-|:-|
| Protocol | Required | String | The name of the protocol on which the pipeline will be applied. The protocol is created, if it does not already exist.|
| Datasets | Optionnal | String | List of datasets. |
| Pipeline | Required | String | Path to a previously created [pipeline](../Brainstorm-Tool/domaine/pipeline/README.md). 

## Is your Analysis File valid ?
An Analysis File is valid if it respects the following rules:
- If the _Protocol_ field contains a new protocol, the first process in the pipeline must me _Create Subject_.
- If the _Datasets_ field is empty, the first process in the pipeline must be either _Create Subject_ or _Review Raw Files_.
- If the pipeline contains the process _Create Subject_, the next process must be _Review Raw Files_.

[datetime documentation]: https://www.mathworks.com/help/matlab/matlab_prog/set-display-format-of-date-and-time-arrays.html
[Brainstorm]: https://neuroimage.usc.edu/brainstorm/Installation
[Runtime]: https://fr.mathworks.com/products/compiler/matlab-runtime.html
