#!/bin/bash

#SBATCH --job-name=lagoon
#SBATCH --partition=long
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16GB

cd /shared/projects/darkdino/lagoon-mcl/darkdino_final_final

module load nextflow slurm-drmaa graphviz

nextflow run main.nf -profile custom,singularity -c conf/abims.config -w /scratch2/darkdino/work -resume
