#!/bin/bash
#USER=$1 #sXXXXXXXX
PROJECT_NAME=segment
set_name=$1

echo "You are on branch scratch so are setting up the DFS for use with scratch."
echo "This unzips an input tar but this is not necessary for some scripts. It is for training."
echo "Press Ctrl+C if this is not correct and switch to the correct branch."

project_path=/home/${USER}/${PROJECT_NAME}
dfs_input_path="${project_path}/data/input"

if [ $# -eq 0 ]; then
  echo "Set name has been left blank, using input.tar.bz2"
  if [ -f "${dfs_input_path}/input.tar.bz2" ]; then
    tar --exclude="._*" -xjvf "${dfs_input_path}/input.tar.bz2" -C "${dfs_input_path}/.."
    rm -rf "${dfs_input_path}/input.tar.bz2"
  else
    echo "Could not find '${dfs_input_path}/input.tar.bz2'"
  fi

else
  echo "Set name is: ${set_name}"
  if [ -f "${dfs_input_path}/${set_name}.tar.bz2" ]; then
    tar --exclude="._*" -xjvf "${dfs_input_path}/${set_name}.tar.bz2" -C "${dfs_input_path}/"
    rm -rf "${dfs_input_path}/${set_name}.tar.bz2"
  else
    echo "Could not find '${dfs_input_path}/${set_name}.tar.bz2'"
  fi
fi