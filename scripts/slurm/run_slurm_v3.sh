#!/bin/bash

#SBATCH --job-name=TestNextflowRun
#SBATCH --partition=long
#SBATCH --time=48:00:00

cd /shared/projects/darkdino/test_nextflow/test_lagoon_mcl_emile_faure

module load nextflow slurm-drmaa graphviz

nextflow run main.nf -profile singularity \
    --projectName lagoon-mcl-emile-faure \
    --fasta "data/fasta/*.faa" \
    --outdir results-emile-faure \
    --scan_gene3d true \
    --scan_esm_atlas true \
    --scan_alphafold_db false \
    --peptides_column protein_accession \
    --annotation_files "data/annotations/*.tsv" \
    --run_diamond true \
    --diamond_db reference \
    --diamond diamond_alignment.tsv \
    --sensitivity sensitive \
    --matrix BLOSUM62 \
    --diamond_evalue 0.001 \
    --I 1.4,2,4 \
    --max_weight 350 \
    -c conf/abims.config
