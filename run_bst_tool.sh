# Check number of arguments
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo -e "Invalid number of arguments. Expected either 3 or 4 arguments:"
    echo -e "run_bst_tool.sh\e[3m matlab_root bids_directory pipeline additional_files (optionnal)\e[0m"
    exit 1
fi

# Get arguments
matlab_root=$1
bids_dir=$2
pipeline_path=$3

# Check number of arguments
if [ "$#" -eq 3 ]; then
    # Default value
    additional_files_path_default_value="-"
    additional_files_path=$additional_files_path_default_value
else
    additional_files_path=$4
fi


# Check if MATLAB Runtime folder exists
if [ ! -d "$matlab_root" ]; then
    echo -e "ERROR> MATLAB Runtime folder does not exist:"
    echo -e "$matlab_root"
    exit 1
fi

# Check if BIDS directory exists
if [ ! -d "$bids_dir" ]; then
    echo -e "ERROR> BIDS directory does not exist:"
    echo -e "$bids_dir"
    exit 1
fi

# Check if pipeline exists
if [ ! -f "$pipeline_path" ]; then
    echo -e "ERROR> Pipeline does not exist:"
    echo -e "$pipeline_path"
    exit 1
fi

# Check if addtionnal_files is not empty and if it exists
if [ "$additional_files_path" != "$additional_files_path_default_value" ] && [ ! -d "$additional_files_path" ]; then
    echo -e "ERROR> Additional files folder does not exist:"
    echo -e "$additional_files_path"
    exit 1
fi

# Get current file directory
current_file_dir=$(realpath $(dirname "$0"))

# Build paths
command_file=$(realpath "${current_file_dir}/../bin/brainstorm3.command")
matlab_script=$(realpath "${current_file_dir}/functions/bst_tool.m")

# Build instruction
instruction="${command_file} ${matlab_root} ${matlab_script} ${bids_dir} ${pipeline_path} ${additional_files_path} local"

# Display instruction
echo -e "\n"$instruction"\n"

# Display version
echo -e "Brainstorm Wrapper Version: 15-FEB-2024"

# Execute
$instruction

# Display exit code and exit
exit_code=$?
echo "Exit code: ${exit_code}"
exit $exit_code
