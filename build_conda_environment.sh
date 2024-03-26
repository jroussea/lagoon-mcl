#!/usr/bin/env bash

# PLEASE DO NOT MODIFY THIS FILE (UNLESS YOU KNOW WHAT YOU DOING)

start=`date`

conda env create -p $PWD/containers/conda/darkdino_1_0  -f $PWD/containers/conda/darkdino_1_0.yaml
conda env create -p $PWD/containers/conda/diamond_2_1_8 -f $PWD/containers/conda/diamond_2_1_8.yaml
conda env create -p $PWD/containers/conda/mcl_22_282  -f $PWD/containers/conda/mcl_22_282.yaml
conda env create -p $PWD/containers/conda/seqkit_2_6_1  -f $PWD/containers/conda/seqkit_2_6_1.yaml

end=`date`

echo -e "\nstart: "$start
echo -e "\nend: "$end
