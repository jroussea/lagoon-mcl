#!/usr/bin/env bash

diamond_aln=${1}

awk '$1!=$5' $diamond_aln > intermediate_file
        
awk -F "\t" '(($10 >= 80) && (($9 >= ($6 * .8)) || (($9 >= ($2 * .8))))) { print $0 }' intermediate_file > ssn

cut -f 1,5,13 ssn > diamond_ssn.tsv