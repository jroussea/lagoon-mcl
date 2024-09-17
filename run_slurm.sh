#!/bin/bash

#SBATCH --job-name=TestNextflowRun
#SBATCH --partition=fast
#SBATCH --time=0-10:00:00

cd /shared/projects/darkdino/test_nextflow/test_lagoon-mcl

module load nextflow slurm-drmaa graphviz

#wget https://raw.githubusercontent.com/nf-core/configs/master/conf/abims.config

nextflow run main.nf -profile singularity \
    --projectName lagoon-mcl \
    --fasta "test/full/tr_files_test/*.fasta" \
    --outdir results \
    --scan_gene3d true \
    --scan_esm_atlas true \
    --scan_alphafold_db false \
    --peptides_column peptides \
    --annotation_files "test/full/an_files_test/*.tsv" \
    --annotation_attrib database-identifiant,interproscan \
    --information_files test/full/in_files_test/information_files.tsv \
    --information_attrib Phylum_Metdb,Genus_Metdb,trophic_mode \
    --run_diamond true \
    --diamond_db reference \
    --query 1 \
    --subject 2 \
    --evalue 12 \
    --diamond diamond_alignment.tsv \
    --sensitivity sensitive \
    --matrix BLOSUM62 \
    --diamond_evalue 0.001 \
    --I 1.4,2,4 \
    --max_weight 350 \
    -c conf/abims.config