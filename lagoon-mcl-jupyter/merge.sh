#!/usr/bin/env bash

path_folder=${1}
inflation=${2}
type=${3}
outdir=${4}

mkdir $outdir

cd $path_folder

ls *.tsv > list

count=0

while read line
do

    let count++

    name=`echo ${line::length-4}`

    sed '1d' $line > file.tmp

    if [ $count -eq 1 ]
    then

        echo -e "CC\tCC_size\t"$name > column.tmp

        cut -f 1,3 file.tmp > cc.tmp
        cut -f 2 file.tmp > hmsc.tmp
        paste cc.tmp hmsc.tmp > file.tmp

        cat column.tmp file.tmp > file_complete.tmp

    else

        cut -f 2 file.tmp > column_info.tmp

        echo $name > column.tmp

        cat column.tmp column_info.tmp > file_$count.tmp

        paste file_complete.tmp file_$count.tmp > tmp
        mv -f tmp file_complete.tmp

    fi

done < list

name="homogeneity_score_I"$inflation"_"$type".tsv"

mv -f file_complete.tmp $outdir/$name

rm -f column_info.tmp file_*.tmp list column.tmp file.tmp hmsc.tmp cc.tmp