#!/usr/bin/env bash

awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < ${1} > one_line.fasta