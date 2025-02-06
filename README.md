# SAM2_cluster
Repository for running [SAM2](https://github.com/facebookresearch/sam2/tree/main) to segment video on a SLURM cluster.

**This is the DFS branch containing set up scripts**

This code has been separated into two branches, one for use on the cluster Distributed File System (DFS) and one for use
on AFS, the University of Edinburgh file storage system for student desktops. The third branch is called "scratch" and 
when both the AFS and DFS setup is complete, switch to that branch and run the code in the git folder in DFS.

Use the following command with [branch_name] replaced with `afs`, `dfs`, or `scratch` depending on which space you need 
to initialise.
```
git switch [branch name]
```

Save any data in ```/home/{USER}/{PROJECT_NAME}```

Run the following command wherever (it uses absolute paths) to install all the dependencies.

```bash
bash setup.sh  
```

The installation requires input when initialising the conda environment.
It also may take a little while when it reaches:
```
Obtaining file:///home/{USER}/segment/sam2
  Installing build dependencies ... |
```
## File List
Assuming you have installed `cluster-scripts` to your DFS and run the `setup.sh` in AFS then DFS, run the following code 
wherever the repo is downloaded in DFS (usually `/home/{USER}/SAM2_cluster`}:

If `run_experiment` can't be found, you may need to perform the following first:
```
echo 'export PATH=/home/$USER/cluster-scripts/experiments:$PATH' >> ~/.bashrc
source ~/.bashrc
```