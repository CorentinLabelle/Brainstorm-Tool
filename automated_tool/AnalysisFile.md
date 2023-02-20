# Analysis File
An analysis file is a JSON file that contains all the information needed to perform an analysis. An analysis is defined with three fields:
```json
{
  "Pipeline": "Path_To_Pipeline",
  "Protocol": "Protocol_Name",
  "Dataset": []
}
```

**Pipeline**: The value of this field is a path to a pipeline (link). The path can be absolute or relative to the 'Data Directory' defined in the user configuration.

**Protocol**: The name of the protocol.

**Dataset**: The list of datasets to be analyzed.
