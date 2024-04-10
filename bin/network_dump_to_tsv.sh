#!/usr/bin/env bash

mcl_dump=${1}
inflation=${2}
filtration=${3}

count=0

file_name="network_"$inflation"_"$filtration".tsv"

echo -e "CC\tdarkdino_sequence_id" > $file_name

while read cluster
do

echo $cluster > cluster.tmp

awk '{for (i=1;i<=NF;i++) print $i}' cluster.tmp > row_to_column.tmp

awk -v count="$count" 'BEGIN{FS=OFS="\t"}{print count OFS $0}' row_to_column.tmp >> $file_name

let count++

rm -f cluster.tmp row_to_column.tmp

done < $mcl_dump
