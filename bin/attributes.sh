#!/usr/bin/env bash

cor_table=${1}
annotation=${2}
basename=${3}

#echo $cor_table
#echo $annotation
#echo $basename

sed '1d' $annotation > $basename.tmp

cut -f 1 $basename.tmp | sort | uniq > $basename.patterns #script python permettant d'imposer la tabulation pour le séparateur de champs

grep -f $basename.patterns $cor_table > $basename.sequence_id

cat $basename.sequence_id | sort > $basename.sequence_id_sort

paste -d ";" $basename.patterns $basename.sequence_id_sort > $basename.tab

#head -n 1 $basename.patterns $basename.sequence_id > $basename.out
#paste -d ";" $basename.patterns $basename.sequence_id > $basename.out
