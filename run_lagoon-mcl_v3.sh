#!/usr/bin/env bash

nextflow run main.nf -profile singularity \
    --max_cpus 15 \
    --max_memory '60.GB' \
    --max_time '336.h' \
    --projectName lagoon-mcl-emile \
    --fasta "test/full/tr_files_test/*.fasta" \
    --outdir results-2 \
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
    -resume
