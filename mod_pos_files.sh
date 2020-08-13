#!/bin/bash

for i in data/CancerChr{21..22}.pos.txt; do
  echo
  CHROM=$(echo $i | egrep -o '2[12]{1}')
  POSVAR=$(echo `head -n1 $i | awk -F , '{print $3}'`)

  if [ "$POSVAR" = "$CHROM" ]; then 
    echo "Already added Chromosome ID to $i"
  elif [ "$POSVAR" = "" ]; then
    sed -e "s/$/, $CHROM/" -i $i
    echo $i now has chromsome ID added
    head -n2 $i
  fi
  echo
done
