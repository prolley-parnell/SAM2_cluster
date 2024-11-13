#USER=$1 #sXXXXXXXX
PROJECT_NAME=segment
afs_src=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/input #s20 is the first two digits of the student number given in $USER

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

project_path=/home/${USER}/${PROJECT_NAME}

#Make the project path if it is not present
if [ ! -d "${project_path}" ]; then
  mkdir -p ${project_path}
fi

dfs_dst="${project_path}/data/input"

#Make the data input path if it is not present
if [ ! -d ${dfs_dst} ]; then
  mkdir -p ${dfs_dst}
fi

#Synchronise the folders and move the AFS input to DFS input
rsync --archive --update --compress --progress ${afs_src}/ ${dfs_dst}
#Code stops after this line - not sure why

#Clone the SAM2 repo -if it is not already present
if [ ! -d "${project_path}/sam2" ]; then
  cd ${project_path} || echo "Could not enter folder ${project_path}" && exit
  git clone https://github.com/facebookresearch/sam2.git
  conda create -n sam2 python=3.10
  conda activate sam2
  #To resolve issues with downloading packages to a /tmp folder that is not big enough
  TMPDIR="${project_path}/tmp"
  TMP="${TMPDIR}"
  TEMP="${TMPDIR}"
  mkdir -p "${TMPDIR}"
  export TMPDIR TMP TEMP
  cd sam2
  pip install -e .
  conda env config vars set SAM2_HOME="${project_path}/sam2"
  conda deactivate
fi

#Download the SAM2 checkpoints if checkpoints folder does not already exist - Edited because it does not need to be imported with new data
if [ ! -d "${project_path}/sam2/checkpoints" ]; then
  #Run any installation commands
  mkdir -p "${project_path}/sam2/checkpoints"
  wget -P "${project_path}/sam2/checkpoints" https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_large.pt
fi




