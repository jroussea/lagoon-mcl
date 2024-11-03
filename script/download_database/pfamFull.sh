#!/usr/bin/env bash

function print_usage() {
    echo -e "Download Pfam"
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
mmseqs databases Pfam-A.full $OUTPUT/pfamFull tmp
rm -f $OUTPUT/tmp