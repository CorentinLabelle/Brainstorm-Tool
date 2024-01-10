# Brainstorm Tool
This tool is a wrapper around [Brainstorm](https://neuroimage.usc.edu/brainstorm/Introduction) hosted on [CBRAIN](https://mcin.ca/technology/cbrain/) that allows the user to execute pipelines on EEG-BIDS dataset. The tutorial on how to use the tool on CBRAIN can be found [here](https://aces.github.io/cbrain-book/2-interfaces/user_User-Guides.html#getting-started).

## Pipelines
Pipelines can be saved in two different formats, either `MAT` or `JSON`. Executing a MATLAB `M` file will not be an option.

### `MAT`
This is the easiest solution. The compiled version of Brainstorm will soon be available on the [EEGNet platform](https://eegnet-dev.loris.ca/). Using the [interface](https://neuroimage.usc.edu/brainstorm/Tutorials/PipelineEditor?highlight=%28pipeline%29#Saving_a_pipeline), pipelines can be created and exported to `MAT` files.

### `JSON`
To create a valid pipeline in a `JSON` format, refer to this [repository](https://github.com/CorentinLabelle/Brainstorm-Tool-Additional-Files/tree/main/pipeline).

## Boutique Descriptor
The [Boutique Descriptor](https://boutiques.github.io/) of the tool has to be in a different [repository](https://github.com/CorentinLabelle/cbrain-plugins-brainstorm).

## Report an issue
If you experience any issues/bug with this tool, feel free to open a new issue on this repo or report it to the following address: corentinlabelle2@gmail.com
