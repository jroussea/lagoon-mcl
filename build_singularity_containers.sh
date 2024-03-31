#!/usr/bin/env bash

# PLEASE DO NOT MODIFY THIS FILE (UNLESS YOU KNOW WHAT YOU DOING)

start=`date`

singularity build --fakeroot $PWD/containers/singularity/lagoon_mcl_1-0-0.sif $PWD/containers/singularity/lagoon_mcl_1-0-0.def
singularity build --fakeroot $PWD/containers/singularity/seqkit_2.6.1.sif $PWD/containers/singularity/seqkit_2.6.1.def
singularity build --fakeroot $PWD/containers/singularity/diamond_2.1.8.sif $PWD/containers/singularity/diamond_2.1.8.def
singularity build --fakeroot $PWD/containers/singularity/mcl_22-282.sif $PWD/containers/singularity/mcl_22-282.def

end=`date`

echo -e "\nstart: "$start
echo -e "\nend: "$end
