#!/bin/bash

#SBATCH --job-name=LAGOON-MCL
#SBATCH --partition=long
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --mem=5GB

cd /shared/projects/darkdino/dinoflagellate/pipelines/lagoon-mcl

module load nextflow slurm-drmaa graphviz

nextflow run main.nf \
    -profile singularity \
    --projectName lagoon-mcl \
    --fasta "/shared/projects/darkdino/dinoflagellate/pipelines/data-darkdino/fasta/*.fasta" \
    --outdir results \
    --peptides_column protein_accession \
    --scan_gene3d false \
    --gene3d_aln "/shared/projects/darkdino/dinoflagellate/pipelines/data-darkdino/gene3d/*.crh.csv" \
    --scan_esm_atlas false \
    --esm_aln "/shared/projects/darkdino/dinoflagellate/pipelines/data-darkdino/esm/*.tsv" \
    --scan_alphafold_db false \
    --alphafold_aln "/shared/projects/darkdino/dinoflagellate/pipelines/data-darkdino/alphafold/*.tsv" \
    --annotation_files "/shared/projects/darkdino/dinoflagellate/pipelines/data-darkdino/annotations/*.tsv" \
    --run_diamond true \
    --diamond_db reference \
    --diamond diamond_alignment.tsv \
    --sensitivity sensitive \
    --matrix BLOSUM62 \
    --diamond_evalue 0.001 \
    --I 1.4,2,4 \
    --max_weight 350 \
    -c conf/abims.config
