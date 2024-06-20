#!/usr/bin/env bash

path_folder=${1}

cd $path_folder

ls *.tsv > list

count=0

while read name
do

    let count++

    inflation=`echo $name | cut -d "_" -f 3`

    cc="CC_"$inflation
    size="CC_size_$inflation"

    sed -e "s/CC/$cc/" -e "s/CC_size/$size/" $name > file_$count.tmp

done < list 

paste file_*.tmp > homogeneity_score.tsv

rm -f list file.tmp file_*.tmp