# SAM2_cluster
Repository for running the SAM2 scripts to segment video on a SLURM cluster.

This code has been separated into two branches, one for use on the cluster Distributed File System (DFS) and one for use on AFS, the University of Edinburgh file storage system for student desktops.

```
bash setup.sh {STUDENT_NUMBER} {PROJECT_NAME}
```

Save any data in ```/home/{USER}/{PROJECT_NAME}```