#USER=$1 #sXXXXXXXX
PROJECT_NAME=segment
afs_data_path=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data #s20 is the first two digits of the student number given in $USER

echo "You are on branch dfs so are setting up the DFS."
echo "Press Ctrl+C if this is not correct and switch to the correct branch."

#Install miniconda if it is not already installed
conda_path=/home/${USER}/miniconda3
if [ ! -d "${conda_path}" ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "${conda_path}"/miniconda.sh
  bash "${conda_path}"/miniconda.sh -b -u
  rm "${conda_path}"/miniconda.sh
  source "${conda_path}"/bin/activate
  conda init --all
  conda config --set auto_activate_base false
fi

dfs_project_path=/home/${USER}/${PROJECT_NAME}

#Make the project path if it is not present
if [ ! -d "${dfs_project_path}" ]; then
  mkdir -p ${dfs_project_path}
fi

#dfs_input_path="${dfs_project_path}/data/input"

#Make the data input path if it is not present
#if [ ! -d ${dfs_input_path} ]; then
#  mkdir -p ${dfs_input_path}
#fi

#Synchronise the folders and move the AFS input to DFS input
#rsync --archive --update --compress --progress ${afs_input_path}/ ${dfs_input_path}
#
#echo "${afs_input_path}/ up to date with ${dfs_input_path}"

#Clone the SAM2 repo -if it is not already present
if [ ! -d "${dfs_project_path}/sam2" ]; then
  cd ${dfs_project_path} || echo "Could not enter folder ${dfs_project_path}" && exit
  git clone https://github.com/facebookresearch/sam2.git
  conda create -n sam2 python=3.10
  conda activate sam2
  #To resolve issues with downloading packages to a /tmp folder that is not big enough
  TMPDIR="${dfs_project_path}/tmp"
  TMP="${TMPDIR}"
  TEMP="${TMPDIR}"
  mkdir -p "${TMPDIR}"
  export TMPDIR TMP TEMP
  cd sam2
  pip install -e .
  pip install pycocotools
  conda env config vars set SAM2_HOME="${dfs_project_path}/sam2"
  conda deactivate
  rm -rf ${TMPDIR}
fi

#Download the SAM2 checkpoints if checkpoints folder does not already exist - Edited because it does not need to be imported with new data
#if [ ! -f "${dfs_project_path}/sam2/checkpoints/sam2.1_hiera_base_plus.pt" ]; then
#  #Run any installation commands
#  mkdir -p "${dfs_project_path}/sam2/checkpoints"
#  wget -P "${dfs_project_path}/sam2/checkpoints" https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_base_plus.pt
#fi

if [ ! -f "${dfs_project_path}/sam2/checkpoints/sam2.1_hiera_large.pt" ]; then
  #Run any installation commands
  mkdir -p "${dfs_project_path}/sam2/checkpoints"
  wget -P "${dfs_project_path}/sam2/checkpoints" https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_large.pt
fi

rsync --archive --update --compress --progress "${afs_data_path}/input.tar.bz2" "${dfs_project_path}/data"

#Ensure that you can use the "run_experiments" wrapper
#echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
if [ -f "${dfs_project_path}/data/input.tar.bz2" ]; then
  tar --exclude="._*" -xjvf "${dfs_project_path}/data/input.tar.bz2" -C "${dfs_project_path}/data"
  rm -rf "${dfs_project_path}/data/input.tar.bz2"
else
  echo "Could not find '${dfs_project_path}/data/input.tar.bz2'"
fi