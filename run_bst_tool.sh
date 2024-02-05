# Check number of arguments
if [ "$#" -ne 3 ]; then
    echo -e "Invalid number of arguments. Expected 3 arguments:"
    echo -e "run_bst_tool.sh\e[3m matlab_root bids_directory pipeline \e[0m"
    exit 0
fi

# Get arguments
matlab_root=$1
bids_dir=$2
pipeline_path=$3

# Check if MATLAB Runtime folder exists
if [ ! -d "$matlab_root" ]; then
    echo -e "ERROR> MATLAB Runtime folder does not exist:"
    echo -e "$matlab_root"
    exit 0
fi

# Check if BIDS directory exists
if [ ! -d "$bids_dir" ]; then
    echo -e "ERROR> BIDS directory does not exist:"
    echo -e "$bids_dir"
    exit 0
fi

# Check if pipeline exists
if [ ! -f "$pipeline_path" ]; then
    echo -e "ERROR> Pipeline does not exist:"
    echo -e "$pipeline_path"
    exit 0
fi

# Get current file directory
current_file_dir=$(realpath $(dirname "$0"))

# Build paths
command_file=$(realpath "${current_file_dir}/../bin/brainstorm3.command")
matlab_script=$(realpath "${current_file_dir}/functions/bst_tool.m")

# Build instruction
instruction="${command_file} ${matlab_root} ${matlab_script} ${bids_dir} ${pipeline_path} local"

# Display instruction
echo -e "\n"$instruction"\n"

# Display version
echo -e "Brainstorm Wrapper Version: 05-FEB-2024"

# Execute
$instruction
