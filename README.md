# SAM2_cluster
Repository for running [SAM2](https://github.com/facebookresearch/sam2/tree/main) to segment video on a SLURM cluster.

**This is the AFS branch**

This code has been separated into two branches, one for use on the cluster Distributed File System (DFS) and one for use
on AFS, the University of Edinburgh file storage system for student desktops. The third branch is called "scratch" and 
when both the AFS and DFS setup is complete, switch to that branch and run the code in the git folder in DFS.

Use the following command with [branch_name] replaced with `afs`, `dfs`, or `scratch` depending on which space you need 
to initialise.
```
git switch [branch name]
```

Save any data in ```/home/{USER}/{PROJECT_NAME}```

## File List
`experiments.txt` - Passed as an argument to the `array_job.sh` with each line consisting of an experiment name. 
Each experiment name is in the `[segment_folder]/data/input` file with a `.tar.bz2` file containing video frames and an annotation `.csv`.
A subset of `experiments_full.txt`.

`experiments_full.txt` - A full list of all the particular experiment names that will be evaluated by this code, saved for future reference.

`segment.py` - The code that performs the segmentation using SAM2 and exports the result as `.npz`

`single_job.sh` - A single instance that calls `segment.py` with arguments

The structure for the `array_job.sh` is taken from [cluster-scripts](https://github.com/cdt-data-science/cluster-scripts/tree/master). This is an incredibly useful repo for use with SLURM. Details on how to use this file are contained within it.

Assuming you have installed `cluster-scripts` to your DFS and run the `setup.sh` in AFS then DFS, run the following code 
wherever the repo is downloaded in DFS (usually `/home/{USER}/SAM2_cluster`}:

```
run_experiment -b array_job.sh -e experiments.txt -m 12
```

If `run_experiment` can't be found, you may need to perform the following first:
```
echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
source ~/.bashrc
```