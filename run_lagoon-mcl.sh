#!/usr/bin/env bash

# The -resume option is enabled by default. 
# If you don't want to use it, delete the last line (\ -resume)

# The default environment / container manager is conda
# To modify it, change the value of the -profile option to mamba, singularity or docker

# The default option for the --information parameter is true.
# You can change it to false if you don't want to use it

# -profile mamba or conda or docker or singularity   [ default: conda ]

# --help = false

# --help true or false               (bool)          [ default: false ]

# --max_cpus 15                      (integer)       [ default: 15 ]
# --max_memory '60.GB'               (string)        [ default: '60.GB' ]
# --max_time '336.h'                 (string)        [ default: '336.h' ]

# --projectName "lagoon-mcl_workdir" (string)        [ default: null ]

# --fasta "null"                     (string - path) [ default: null ]

# --outdir "$baseDir/results"        (string - path) [ default: "$baseDir/results" ]

# --scan_gene3d true or false        (bool)          [ default: true ]
# --gene3d_aln "null"                (string - path) [ default: null ]

# --scan_esm_atlas true or false     (bool)          [ default: true ]
# --esm_aln "null"                   (string - path) [ default: null ]

# --scan_alphafold_db true or false  (bool)          [ default: false ]
# --alphafold_aln "null"             (string - path) [ default: null ]

# --peptides_column "null"           (string)        [ default: null ]

# --annotation_files "null"          (string - path) [ default: null ]
# --annotation_attrib "null"         (string)        [ default: null ]

# --information_files "null"         (string - path) [ default: null ]
# --information_attrib "null"        (string)        [ default: null ]

# --run_diamond true or false        (bool)          [ default: true ]

# --diamond_db reference             (string)        [ default: reference ]

# --alignment_file "null"            (string - path) [ default: null ]

# --query 1                          (integer)       [ default: 1 ]
# --subject 2                        (integer)       [ default: 2 ]
# --evalue 12                        (integer)       [ default: 12 ]

# --diamond "diamond_alignment.tsv   (string)        [ default: diamond_alignment.tsv ]
# --sensitivity fast or              (string)        [ default: sensitive ]
#               mid-sensitive or
#               more-sensitive or
#               very-sensitive or
#               sensitive or
#               ultra-sensitive
# --matrix BLOSUM45 or               (string)        [ default: BLOSUM62 ]
#          BLOSUM50 or 
#          BLOSUM62 or
#          BLOSUM80 or
#          BLOSUM90 or
#          PAM250 or 
#          PAM70 or
#          PAM30       
# --diamond_evalue 0.001             (float)         [ default: 0.001 ]

# --I 1.4,2,4 (float - list) [ default: 1.4,2,4 ]
# --max_weight 350 (integer) [ default: 350 ]

nextflow run main.nf -profile mamba \
    --max_cpus 15 \
    --max_memory '60.GB' \
    --max_time '336.h' \
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
    -resume
