#!/usr/bin/env bash

echo -e "\nCE PROGRAMME UTILISE SINGULARITY\n"

# VARIABLES
SCRIPT=$PWD"/bin"
DATABASE=$PWD"/../database"
CONTAINER=$PWD"/../containers"
LAGOON=$CONTAINER/lagoon-mcl/1.1.0/lagoon-mcl.sif
SEQKIT=$CONTAINER/seqkit/2.9.0/seqkit.sif
MMSEQS2=$CONTAINER/mmseqs2/15.6f452/mmseqs.sif

echo -e "\nListe des Variables :"
echo -e "DATABASE OUTPUT: $DATABASE"
echo -e "CONTAINERS: $CONTAINER"
echo -e "MMSEQ2: $MMSEQS2\n"

echo -e "\nDOWNLOAD AND BUILD PFAM FULL\n"
cd $DATABASE
PATHDB=$PWD
mkdir pfamDB ; cd pfamDB
singularity run $MMSEQS2 mmseqs databases Pfam-A.full pfamDB tmp
rm -rf tmp

echo -e "\n=====================================\n"

echo -e "Pour utiliser Pfam database avvec LAGOON-MCL, utiliser les paramètres:"
echo -e "--pfamDB $PATHDB/pfamDB"
echo -e "--pfamDB_name pfamDB"

echo -e "\n=====================================\n"
