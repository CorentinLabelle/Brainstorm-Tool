# Automated Brainstorm Tool
The automated tool is a function that can be used within the Matlab environment or through the command window using the Matlab Runtime. The function can be used to apply a pipeline to a list of dataset. It takes only one argument, which is the link to an Analysis File (.json). The pipeline is applied using the Brainstorm functions.

## Requirements
- [Brainstorm]
- [Runtime R2020a (9.8)]

## Brainstorm Database
The Brainstorm database contains the protocols. A protocol contains a list of subjects and, for every subject, a list of datasets. Adding a dataset to a subject is done using the process _Review Raw Files_. The dataset can then be analyzed using different processes (filters, ica, etc.). Brainstorm does not actually apply the processes until the dataset is imported in the database. This is done using the process _Import Time_. This is why the last process of the pipeline must be _Import Time_.

## Analysis File description
The _Protocol_ key is required. If the protocol does not exist, the protocol is created. In this case, the first two processes in the pipeline must be _Create New Suject_ and _Review Raw Files_.
| Keyname | Requirement Level | Data Type | Description |
|:-|:-|:-|:-|
| Protocol | Required | String | The name of the protocol on which the pipeline will be applied. The protocol is created, if it does not already exist.|
| sFiles | Optionnal | String | List of datasets. If this field is empty (or non-existent), the first process in the list of processes needs to be ‘Review Raw Files’.|
| Pipeline | Required | Pipeline | See [Pipeline description](Pipeline-description). |

## Pipeline description
| Keyname | Requirement Level | Data Type | Description |
|:-|:-|:-|:-|
| Name | Optionnal | String | Pipeline’s Name. |
| Folder | Optionnal | String | Pipeline’s Folder. |
| Extension | Optionnal | String | Indicates the extension of the pipeline (.mat, .json) |
| DateOfCreation | Optionnal | Datetime | Indicates the date of creation of the pipeline. See [datetime documentation] for the possible date format. |
| Process | Required | Process Object | List of processes. See [Process description](Process-description). |
| Documentation | Optionnal | String | Documentation about the pipeline. |
| History | Optionnal | String | Information about every function applied to the pipeline. |

## Process description
| Keyname | Requirement Level | Data Type | Description |
|:-|:-|:-|:-|
| Name | Required | String | Process' Name. |
| DateOfCreation | Optionnal | Datetime | Indicates the date of creation of the process. See [datetime documentation] for the possible date format. |
| Parameters | Required | Parameter Object | The parameters are specific to every process. See [Example of Analysis File](Example-of-Analysis-File). |
| Documentation | Optionnal | String | Documentation about the process. |
| History | Optionnal | String | Still unavailable... |

## Is your Analysis File valid ?
You can find a template of an Analysis File [here](AnalysisFileTemplate.json).
An Analysis File is valid if it respects the following rules:
- If the _sFiles_ field is empty, the first process in the pipeline must be either _Create Subject_ or _Review Raw Files_.
- If the _Protocol_ field contains a new protocol, the first process in the pipeline must me _Create Subject_.
- If the pipeline contains the process _Create Subject_, the next process must be _Review Raw Files_.

[datetime documentation]: https://www.mathworks.com/help/matlab/matlab_prog/set-display-format-of-date-and-time-arrays.html
[Brainstorm]: https://neuroimage.usc.edu/brainstorm/Installation
[Runtime R2020a (9.8)]: https://fr.mathworks.com/products/compiler/matlab-runtime.html
