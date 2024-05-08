#!/usr/bin/env bash

nextflow run main.nf -profile mamba \
    --max_cpus 15 \
    --max_memory '60.GB' \
    --max_time '336.h' \
    --projectName LAGOON-MCL \
    --fasta "test/full/tr_files_test/*.fasta" \
    --annotation "test/full/an_files_test/*.tsv" \
    --pep_colname peptides \
    --columns_attributes database-identifiant,interproscan \
    --concat_fasta all_sequences \
    --information true \
    --information_files test/full/in_files_test/information_files.tsv \
    --information_attributes Phylum_Metdb,Genus_Metdb,trophic_mode \
    --outdir results \
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
    --max_weight 350
