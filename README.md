# SAM2_cluster
Repository for running [SAM2](https://github.com/facebookresearch/sam2/tree/main) to segment video on a SLURM cluster.

This code has been separated into two branches, one for use on the cluster Distributed File System (DFS) and one for use on AFS, the University of Edinburgh file storage system for student desktops.
The third branch is called "scratch" and when both the AFS and DFS setup is complete, switch to that branch and copy the git repo to the scratch space.

`PROJECT_NAME=segment`


```
bash setup.sh {STUDENT_NUMBER} {PROJECT_NAME}
```

Save any data in ```/home/{USER}/{PROJECT_NAME}```

## File List
`experiments.txt` - Passed as an argument to the `slurm_arrayjob.sh` with each line consisting of a relative path to a `.tar`file containing video frames and an annotation `.csv`. A subset of `experiments_full.txt`.

`experiments_full.txt` - A full list of all the particular experiment names that will be evaluated by this code, saved for future reference.

`segment.py` - The code that performs the segmentation using SAM2 and exports the result as `.npy`

`single_job.sh` - A single instance that calls `segment.py` with arguments

The structure for the `array_job.sh` is taken from [cluster-scripts](https://github.com/cdt-data-science/cluster-scripts/tree/master). This is an incredibly useful repo for use with SLURM. Details on how to use this file are contained within it.
