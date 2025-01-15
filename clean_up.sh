#!/bin/sh
PROJECT_NAME=segment
project_path=/home/${USER}/${PROJECT_NAME}

echo "You are cleaning up, this will delete any output files left in the dfs after running rsync"
echo "Do you wish to continue? [y/n]"

read response < /dev/tty
if [ ! "$response" = "y" ] ; then
  exit
fi

dfs_output_path="${project_path}/data/output"
afs_output_path="/afs/inf.ed.ac.uk/user/s20/${USER}/${PROJECT_NAME}/data/output"


#Make the data output path if it is not present
mkdir -p ${afs_output_path}

#Synchronise the folders and move the AFS input to DFS input
rsync --archive --update --compress --progress ${dfs_output_path}/ ${afs_output_path}
echo "${dfs_output_path}/ up to date with ${afs_output_path}"

rm -rf ${dfs_output_path}
