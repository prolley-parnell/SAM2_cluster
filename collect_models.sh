#!/bin/sh
SCRATCH_DISK=/disk/scratch
SCRATCH_HOME=${SCRATCH_DISK}/${USER}
project_name=sleap
src_path=${SCRATCH_HOME}/${project_name}/data/models
dst_path=/home/${USER}/${project_name}/data/models
mkdir -p ${dst_path}
rsync --archive --update --compress --progress ${src_path}/ ${dst_path}