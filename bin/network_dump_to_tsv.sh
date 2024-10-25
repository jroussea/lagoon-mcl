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

while getopts ":m:i:c:" PARAM; do
   case "$PARAM" in
      m) mcl_dump=$OPTARG;;
      i) inflation=$OPTARG;;
      c) column=$OPTARG;;
      \?) print_usage; exit 1 ;;
      h) print_usage; exit 1 ;;
   esac
done

count=0
file_name="network_I"$inflation".tsv"

# création d'un fichier TSV à 2 colonne : colonne 1 = identifiant du cluster (0,1,2,...X), colonne 2 : noudeau dans le réseau
while read cluster
do
    echo $cluster > cluster.tmp
    awk '{for (i=1;i<=NF;i++) print $i}' cluster.tmp > row_to_column.tmp
    awk -v count="$count" 'BEGIN{FS=OFS="\t"}{print count OFS $0}' row_to_column.tmp >> intermediate.file
    let count++
done < $mcl_dump

# ajout d'une troisième colonne : contient le paramè-ètre d'inflation utilisé pour le clustering
echo -e "cluster_id\t"$column"\tinflation" > header
awk -v inflation=$inflation 'BEGIN{FS=OFS="\t"}{print $0, inflation}' intermediate.file > intermediation.file.2
cat header intermediation.file.2 > $file_name