#!/usr/bin/env bash

function print_usage() {
    echo -e "Download ESM Metagenomic Atlas"
    echo -e "Construction and indexation with MMseqs2\n"
    echo -e "Option:"
    echo -e "-o  Output directory where the database is stored"
}

if [ "$1" == "" ] ; then
    print_usage
    exit 0
fi

while getopts ":o:" PARAM; do
    case "$PARAM" in
        o) OUTPUT=$OPTARG;;
        \?) print_usage; exit 1 ;;
        h) print_usage; exit 1 ;;
    esac
done

mkdir $OUTPUT ; cd $OUTPUT
wget -c https://dl.fbaipublicfiles.com/esmatlas/v0/highquality_clust30/highquality_clust30.fasta
mmseqs createdb highquality_clust30.fasta esmAtlas30
mmseqs createindex esmAtlas30 tmp