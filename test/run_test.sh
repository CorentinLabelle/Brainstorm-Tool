# First argument
matlab_root=$1
if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
    echo "There should be exactly one input which is the path to the Matlab Runtime directory."
    exit 1
fi

# Get current file directory
current_file_dir=$(dirname "$0")
cd $current_file_dir

# Build paths
data="${PWD}/data/Face13_S01_S02"
pipeline="${PWD}/pipeline/eeg_pre_processing.json"

# Move to compile folder
cd "${PWD}/../compiled_tool"

# Build instruction
instruction="bash ./run_bst_tool.sh ${matlab_root} ${data} ${pipeline}"

# Display instruction
# echo -e '\n'$instruction'\n'

# Execute
$instruction