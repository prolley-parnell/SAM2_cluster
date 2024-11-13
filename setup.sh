#Run this from device connected to drive with data
USER=$1 #sXXXXXXX
input_folder=$2 #Path to the /data folder that contains an input directory that is not zipped
PROJECT_NAME=segment
afs_project_path=/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME} #The s20 is the first two numbers of the user student number


#Make the project path in AFS if it does not exist already
if [ ! -d "${afs_project_path}" ]; then
  mkdir -p ${afs_project_path}
fi

#If there is no data/input folder in the project folder, then make it.
afs_src="${afs_project_path}/data/input"

if [ ! -d ${afs_src} ]; then
  mkdir -p ${afs_src}
fi

if [ ! -f "${input_folder}/input.tar.bz2" ]; then
  cd ${input_folder}
  tar --no-xattrs --exclude="._*" -cjf input.tar.bz2 -C input
  mv input.tar.bz2 ${afs_src}
fi

#Download the SAM2 checkpoints to AFS if the checkpoints folder does not already exist
if [ ! -d "${afs_src}/checkpoints" ]; then
  #Run any installation commands
  mkdir -p "${afs_src}/checkpoints/"
  wget -P "${afs_src}/checkpoints/" https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_large.pt
fi

