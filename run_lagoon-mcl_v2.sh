#!/usr/bin/env bash

nextflow run main.nf \
    -profile singularity \
    --max_cpus 15 \
    --max_memory '60.GB' \
    --max_time '336.h' \
    --projectName lagoon-mcl-3 \
    --fasta "test/reduced/trancriptome/*.fasta" \
    --outdir results-3 \
    --scan_gene3d false \
    --gene3d_aln "test/reduced/gene3d/*.csv" \
    --scan_esm_atlas false \
    --esm_aln "test/reduced/esm_aln/*.tsv" \
    --scan_alphafold_db false \
    --alphafold_aln "test/reduced/af_aln/*.tsv" \
    --peptides_column protein_accession \
    --annotation_files "test/reduced/annotation/*.tsv" \
    --information_files test/reduced/information/dinoflagellata_v1.tsv \
    --information_attrib Phylum,Class,Order,Family,Genus,Species \
    --run_diamond true \
    --diamond_db reference \
    --diamond diamond_alignment.tsv \
    --sensitivity sensitive \
    --matrix BLOSUM62 \
    --diamond_evalue 0.001 \
    --I 1.4,2,4 \
    --max_weight 350 \
    -resume
