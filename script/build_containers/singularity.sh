#!/usr/bin/env bash

# --------------------------------------------------------------- #
# PLEASE DO NOT MODIFY THIS FILE (UNLESS YOU KNOW WHAT YOU DOING) #
# --------------------------------------------------------------- #

start=`date`

# Diamond
singularity build \
    --fakeroot \
    $PWD/../../containers/diamond/2.1.8/diamond.sif \
    $PWD/../../containers/diamond/2.1.8/diamond.def

# Markov CLustering algorithm
singularity build \
    --fakeroot \
    $PWD/../../containers/mcl/22.282/mcl.sif \
    $PWD/../../containers/mcl/22.282/mcl.def

# SeqKit2
singularity build \
    --fakeroot \
    $PWD/../../containers/seqkit/2.8.2/seqkit.sif \
    $PWD/../../containers/seqkit/2.8.2/seqkit.def

# MMseqs2
singularity build \
    --fakeroot \
    $PWD/../../containers/mmseqs2/15-6f452/mmseqs.sif \
    $PWD/../../containers/mmseqs2/15-6f452/mmseqs.def

# LAGOON-MCL
singularity build \
    --fakeroot \
    $PWD/../../containers/lagoon-mcl/lagoon-mcl.sif \
    $PWD/../../containers/lagoon-mcl/lagoon-mcl.def

end=`date`

echo -e "\nstart: "$start
echo -e "\nend: "$end
