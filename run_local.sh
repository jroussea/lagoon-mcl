#!/bin/bash

cd /home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup

nextflow run main.nf \
    -profile singularity \
    --projectName lagoon-mcl \
    --fasta "/home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup/test/fasta/*.fasta" \
    --outdir results \
    --peptides_column protein_accession \
    --scan_gene3d true \
    --hmm_profile /home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup/test/database/gene3d/hmms/main.hmm \
    --domain_list /home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup/test/database/gene3d/cath-domain-list.txt \
    --discontinuous /home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup/test/database/gene3d/discontinuous_regs.pkl \
    --scan_esm_atlas true \
    --esm_db /home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup/test/database/esmdb/highquality_clust30.fasta \
    --annotation_files "/home/jrousseau/Documents/git_projects/workflow-laggoon-mcl/lagoon-mcl-recup/test/annotation/*.tsv" \
    --run_diamond true \
    --diamond_db reference \
    --diamond diamond_alignment.tsv \
    --sensitivity sensitive \
    --matrix BLOSUM62 \
    --diamond_evalue 0.001 \
    --I 1.4,2,4 \
    --max_weight 350 \
    -resume
