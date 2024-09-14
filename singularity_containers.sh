#!/usr/bin/env bash

# --------------------------------------------------------------- #
# PLEASE DO NOT MODIFY THIS FILE (UNLESS YOU KNOW WHAT YOU DOING) #
# --------------------------------------------------------------- #

start=`date`

singularity build \
    --fakeroot \
    $PWD/containers/cath-tools_0.16.5/cath-tools.sif \
    $PWD/containers/cath-tools_0.16.5/cath-tools.def

singularity build \
    --fakeroot \
    $PWD/containers/diamond_2.1.8/diamond.sif \
    $PWD/containers/diamond_2.1.8/diamond.def

singularity build \
    --fakeroot \
    $PWD/containers/hmmer_3.4/hmmer.sif \
    $PWD/containers/hmmer_3.4/hmmer.def

singularity build \
    --fakeroot \
    $PWD/containers/mcl_22.282/mcl.sif \
    $PWD/containers/mcl_22.282/mcl.def

singularity build \
    --fakeroot \
    $PWD/containers/lagoon-mcl/lagoon-mcl.sif \
    $PWD/containers/lagoon-mcl/lagoon-mcl.def

end=`date`

echo -e "\nstart: "$start
echo -e "\nend: "$end
