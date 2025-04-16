#!/bin/bash

#SBATCH --job-name=lagoon-mcl
#SBATCH --partition=long
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16GB

cd /path/to/lagoon-MCL

# This script runs LAGOON-MCL on the ABiMS compute cluster (https://abims.sb-roscoff.fr/)
# The modules to be loaded may be different on your system
module load nextflow slurm-drmaa graphviz

# Modify the abims.config file with the file specific to your calculation cluster
nextflow run main.nf -profile custom,singularity -c conf/abims.config -w /path/to/your/working/directory -resume
