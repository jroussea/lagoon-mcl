#!/usr/bin/env bash

proteome=${1}
information_files=${2}
basename=${3}
peptide=${4}

# récupérer le nom des séquences fasta
awk 'sub(/^>/, "")' < $proteome > fasta_header

# mettre le nom des séquences fasta dans le fichier final
awk '{print $1}' fasta_header > $basename.info

# récupéer le nom des colonnes dans le fichier d'information
information=`grep $basename $information_files | cut -f 2-`

# ajoute une nouvelle colonne 
sed -i "s|$|\t$information|g" $basename.info

# récupération des noms es colonnes présent deans le fichier d'informaiton
columns_info_files=`head -n 1 $information_files | cut -f 2-`
# ajout de la colonne peptide
columns_name=`echo -e "$peptide\t$columns_info_files"`

sed -i "1s/^/$columns_name\\n/" $basename.info

#sed -i 1d $basename.info