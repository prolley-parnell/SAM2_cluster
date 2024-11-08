USER=$1 #sXXXXXXXX
PROJECT_NAME=$2
afs_src=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/input #s20 is the first two digits of the student number given in $USER

#Install miniconda if it is not already installed
conda_path=/home/${USER}/miniconda3
if [ ! -d "${conda_path}" ]; then
  mkdir -p "${conda_path}"
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "${conda_path}"/miniconda.sh
  bash "${conda_path}"/miniconda.sh -b -u -p "${conda_path}"
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

#Clone the SAM2 repo -if it is not already present
if [ ! -d "${project_path}/sam2" ]; then
  cd ${project_path} || echo "Could not enter folder ${project_path}" && exit
  git clone https://github.com/facebookresearch/sam2.git
  cd sam2 & pip install -e .
fi

#Copy the config files from SAM2 to the input folder
if [ ! -d "${dfs_dst}/configs" ]; then
  mkdir -p "${dfs_dst}/configs"
  cp "${project_path}/sam2/configs/sam2.1/sam2.1_hiera_l.yaml" "${dfs_dst}/configs/"
fi





