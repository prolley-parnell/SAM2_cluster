#USER=$1 #sXXXXXXXX
PROJECT_NAME=segment
afs_src=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/input #s20 is the first two digits of the student number given in $USER

echo "You are on branch `dfs` so are setting up the DFS."
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

echo "${afs_src}/ up to date with ${dfs_dst}"

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
if [ ! -f "${project_path}/sam2/checkpoints/sam2.1_hiera_large.pt" ]; then
  #Run any installation commands
  mkdir -p "${project_path}/sam2/checkpoints"
  wget -P "${project_path}/sam2/checkpoints" https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_large.pt
fi

#Ensure that you can use the "run_experiments" wrapper
#echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
if [ -f "${dfs_dst}/input.tar.bz2" ]; then
  tar --exclude="._*" -xjvf "${dfs_dst}/input.tar.bz2" -C "${dfs_dst}/"
else
  echo "Could not find '${dfs_dst}/input.tar.bz2'"
fi