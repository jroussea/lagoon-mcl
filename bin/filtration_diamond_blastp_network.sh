#!/usr/bin/env bash

function print_usage() {
  echo ""
  echo ""
  echo ""
}

if [ "$1" == "" ] ; then
  print_usage
  exit 0
fi

while getopts ":a:" PARAM; do
   case "$PARAM" in
      a) diamond_aln=$OPTARG;;
      \?) print_usage; exit 1 ;;
      h) print_usage; exit 1 ;;
   esac
done

# Supprimer les lignes ou l'identifiant dans la colonne query est égal à l'identifiant dans la colonne subjectif
# permet de supprimer les lignes ou la séquence c'est aligné contre elle même
awk '$1!=$5' $diamond_aln > intermediate_file

# filtration des alignements
# ne conserve que les alignement aves une identifé de 80% (par défaut)
# et une couverure de 80 % par défaut
awk -F "\t" '(($10 >= 80) && (($9 >= ($6 * .8)) || (($9 >= ($2 * .8))))) { print $0 }' intermediate_file > ssn

# sélection des colonne query,subject et evalue => utilié pour le clustering avec MCL
cut -f 1,5,13 ssn > diamond_ssn.tsv