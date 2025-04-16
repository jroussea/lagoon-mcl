#!/usr/bin/env bash

date_start=`data`

echo -e "\nTHIS PROGRAM USES SINGULARITY\n"

# VARIABLES
SCRIPT=$PWD"/bin"
DATABASE=$PWD"/../database"
CONTAINER=$PWD"/../containers"
LAGOON=$CONTAINER/lagoon-mcl/1.0.0/lagoon-mcl.sif
SEQKIT=$CONTAINER/seqkit/2.9.0/seqkit.sif
MMSEQS2=$CONTAINER/mmseqs2/15.6f452/mmseqs.sif

echo -e "\nList of Variables:"
echo -e "DATABASE OUTPUT: $DATABASE"
echo -e "CONTAINERS: $CONTAINER"
echo -e "LAGOON: $LAGOON"
echo -e "SEQKIT: $SEQKIT"
echo -e "MMSEQ2: $MMSEQS2"
echo -e "SCRIPT: $SCRIPT\n"

echo -e "\nDOWNLOAD ALPHAFOLD DATABASE\n"
cd $DATABASE
wget https://ftp.ebi.ac.uk/pub/databases/alphafold/sequences.fasta
wget https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz
gunzip 1-AFDBClusters-entryId_repId_taxId.tsv.gz
singularity run $LAGOON python $SCRIPT/download_alphafolddb.py --alphafold 1-AFDBClusters-entryId_repId_taxId.tsv

echo -e "\nEXTRACT ALPHAFOLD CLUSTER SEQUENCES\n"
singularity run $SEQKIT seqkit grep -f sequences_id_alphafold_cluster_foldseek.txt sequences.fasta -o sequences_alphafold_clusters.fasta
rm -f sequences.fasta sequences_id_alphafold_cluster_foldseek.txt sequences.fasta

echo -e "\nBUILD ALPHAFOLD MMSEQS2 DATABASE\n"
PATHDB=$PWD
mkdir alphafoldDB ; cd alphafoldDB
singularity run $MMSEQS2 mmseqs createdb ../sequences_alphafold_clusters.fasta alphafoldDB
rm -f ../sequences_alphafold_clusters.fasta
cd $DATABASE

echo -e "\nDOWNLOAD UNIPROTKB AND EXTRACT PFAM FUNCTION\n"
wget https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz
singularity run $LAGOON python $SCRIPT/uniprot.py --clusters 1-AFDBClusters-entryId_repId_taxId.tsv --uniprot protein2ipr.dat.gz
rm -f 1-AFDBClusters-entryId_repId_taxId.tsv protein2ipr.dat.gz

data_end=`date`

echo -e "\n=====================================\n"

echo "date start: "$date_start
echo "date end: "$date_end

echo -e "Use the following parameters:"
echo -e "--alphafoldDB $PATHDB/alphafoldDB"
echo -e "--alphafoldDB_name alphafoldDB"
echo -e "--uniprot $PATHDB/uniprot_function.json"

echo -e "\n=====================================\n"
