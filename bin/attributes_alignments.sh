#!/usr/bin/env bash

cor_table=${1}
alignment=${2}
columnQuery=${3}
columnSubject=${4}

# query sequence

cut -f $columnQuery $alignment | sort | uniq > column_query.patterns

grep -f column_query.patterns $cor_table > column_query.sequence_id

cat column_query.sequence_id | sort > column_query.sequence_id_sort

paste -d ";" column_query.patterns column_query.sequence_id_sort > column_query.tab

# subject sequence

cut -f $columnSubject $alignment | sort | uniq > column_subject.patterns

grep -f column_subject.patterns $cor_table > column_subject.sequence_id

cat column_subject.sequence_id | sort > column_subject.sequence_id_sort

paste -d ";" column_subject.patterns column_subject.sequence_id_sort > column_subject.tab