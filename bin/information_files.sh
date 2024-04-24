#!/usr/bin/env bash

proteome=${1}
information_files=${2}
basename=${3}
peptide=${4}

awk 'sub(/^>/, "")' < $proteome > fasta_header

awk '{print $1}' fasta_header > $basename.info

information=`grep $basename $information_files`

sed -i "s/$/\t$information/" $basename.info

columns_info_files=`head -n 1 $information_files`
columns_name=`echo -e "$peptide\t$columns_info_files"`

sed -i "1s/^/$columns_name\\n/" $basename.info