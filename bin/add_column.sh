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

while getopts ":i:o:c:" PARAM; do
   case "$PARAM" in
      i) input=$OPTARG;;
      o) output=$OPTARG;;
      c) column=$OPTARG;;
      \?) print_usage; exit 1 ;;
      h) print_usage; exit 1 ;;
   esac
done

sed "s|$|\t$column|" $input > $output
