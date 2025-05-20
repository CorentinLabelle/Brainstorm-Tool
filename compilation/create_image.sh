# Get current file directory
working_directory=$1
container_input=$2

first_image_name="attempt"
container_name="brainstorm"

source check_user.sh
check_user "philippealbouy"

# Move to working directory
# The working directory should contain:
# 1. Matlab Runtime aka "MATLAB_Runtime_R2021a_Update_8_glnxa64.zip"
# 2. A file called "Dockerfile"
echo "-> Changing working directory"
echo "$working_directory"
cd $working_directory

echo "-> Pulling latest ubuntu image"
sudo docker pull ubuntu

echo "-> Building image based on Dockerfile"
sudo docker build --no-cache -t $first_image_name .

echo "-> Running container"
container_id=$(sudo docker run -td --name $container_name $first_image_name)
echo "Container ID"
echo $container_id

echo "-> Adding Matlab Runtime to system path and changing permission for 'run_bst_tool.sh'"
sudo docker exec -it brainstorm bash -c 'export LD_LIBRARY_PATH=:/usr/local/MATLAB/MATLAB_Runtime/v910/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v910/extern/bin/glnxa64; chmod +x /Brainstorm/Brainstorm-Tool/src/run_bst_tool.sh'

echo "-> Commit container ($container_id) to create image"
read -p "Enter image name: " final_image_name
sudo docker commit $container_id $final_image_name

