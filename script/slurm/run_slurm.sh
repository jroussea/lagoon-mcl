#!/bin/bash

#SBATCH --job-name=lagoon
#SBATCH --partition=long
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=5GB

cd /shared/projects/darkdino/lagoon-mcl/test

module load nextflow slurm-drmaa graphviz

nextflow run main.nf -profile custom,singularity -c conf/abims.config -resume
