## Boutique Descriptor
The tool will soon be available in the [Boutiques](https://github.com/boutiques/boutiques). The Brainstorm Tool Boutique Descriptor is still incomplete. The fields 'command-line' and 'container-image' will be updated once the docker container is generated.
```json
{
    "name": "Brainstorm Tool",
    "description": "Enables to perform the pre-processing steps on EEG and MEG data.",
    "tool-version": "v0.1.0",
    "schema-version": "0.5",
    "command-line": "brainstorm3.bat [INPUT_FILE]",
    "container-image": {
        "image": "...",
        "index": "...",
        "type": "singularity"
    },
    "inputs": [
        {
            "id": "infile",
            "name": "Analysis File",
            "optional": false,
            "type": "File",
            "description": "Path to a an analysis file",
            "value-key": "[INPUT_FILE]"
        }
    ],
    "output-files": [
        {
            "id": "outfile",
            "name": "Output File",
            "optional": false,
            "path-template": "[INPUT_FILE]_output.json",
            "path-template-stripped-extensions": [
                ".json"
            ]
        }
    ]
}
```