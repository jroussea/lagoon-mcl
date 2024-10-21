#!/usr/bin/env bash

# Ref: https://www.nature.com/articles/s41467-021-24547-1#Sec20
# Available on fishare: https://figshare.com/articles/dataset/MAGs_protein_functional_clusters_data/12030795

cd ../../test/test_emile-faure-2021

# Download

wget https://figshare.com/ndownloader/files/22163337 -O dataset.tar.gz
wget https://figshare.com/ndownloader/files/22111044 -O protein.faa

# Folder

mkdir annotations fasta split

# annotations

tar -xzf dataset.tar.gz

mv Raw_Data_Figshare/Allprot_eggNOG_Functional_description annotations/eggnog.tsv
mv Raw_Data_Figshare/KOFamScan_AllProt annotations/kofam.tsv

# fasta (proteins)

seqkit split2 protein.faa -s 70000 -O split

cd split ; ls *.faa > ../fasta.lst ; cd ..

while read line
do

name=`echo $line | cut -d "." -f 1,2 | sed 's/\./_/'`".faa"

mv split/$line fasta/$name

done < fasta.lst

rm -rf Raw_Data_Figshare dataset.tar.gz fasta.lst protein.faa split/
