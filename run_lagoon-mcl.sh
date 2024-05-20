#!/usr/bin/env bash

nextflow run main.nf -profile mamba \
    --max_cpus 15 \
    --max_memory '60.GB' \
    --max_time '336.h' \
    --projectName LAGOON-MCL_2 \
    --fasta "test/tr/*.fasta" \
    --annotation "test/an/*.tsv" \
    --pep_colname protein_accession \
    --columns_attributes analysis-signature_accession,interpro_accession \
    --concat_fasta all_sequences \
    --information true \
    --information_files test/dinoflagellata_v3.csv \
    --information_attributes Phylum,Class,Order,Family,Genus,Species \
    --outdir results_2 \
    --run_diamond true \
    --diamond_db reference \
    --alignment_file null \
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
