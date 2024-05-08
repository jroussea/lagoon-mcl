#!/usr/bin/env bash

# --------------------------------------------------------------- #
# PLEASE DO NOT MODIFY THIS FILE (UNLESS YOU KNOW WHAT YOU DOING) #
# --------------------------------------------------------------- #

start=`date`

singularity build --fakeroot $PWD/containers/singularity/lagoon-mcl.sif $PWD/containers/singularity/lagoon-mcl.def

end=`date`

echo -e "\nstart: "$start
echo -e "\nend: "$end
