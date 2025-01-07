#!/bin/bash
#USER=$1 #sXXXXXXXX
PROJECT_NAME=segment

echo "You are on branch scratch so are setting up the DFS for use with scratch."
echo "This unzips an input tar but this is not necessary for some scripts. It is for training."
echo "Press Ctrl+C if this is not correct and switch to the correct branch."

project_path=/home/${USER}/${PROJECT_NAME}
dfs_input_path="${project_path}/data/input"


#Ensure that you can use the "run_experiments" wrapper
#echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
if [ -f "${dfs_input_path}/input.tar.bz2" ]; then
  tar --exclude="._*" -xjvf "${dfs_input_path}/input.tar.bz2" -C "${dfs_input_path}/.."
  rm -rf "${dfs_input_path}/input.tar.bz2"
else
  echo "Could not find '${dfs_input_path}/input.tar.bz2'"
fi
