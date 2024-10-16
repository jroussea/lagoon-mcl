#!/usr/bin/env bash

mcl_dump=${1}
inflation=${2}
column=${3}

count=0

file_name="network_I"$inflation".tsv"

echo -e "CC\t"$column > $file_name

while read cluster
do

echo $cluster > cluster.tmp

#xargs -n1 < cluster.tmp > row_to_column.tmp

awk '{for (i=1;i<=NF;i++) print $i}' cluster.tmp > row_to_column.tmp

awk -v count="$count" 'BEGIN{FS=OFS="\t"}{print count OFS $0}' row_to_column.tmp >> $file_name

let count++

#rm -f cluster.tmp row_to_column.tmp

done < $mcl_dump
