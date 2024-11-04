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
awk '$1!=$5' $diamond_aln > ssn

# sélection des colonne query,subject et evalue => utilié pour le clustering avec MCL
cut -f 1,5,13 ssn > diamond_ssn.tsv
