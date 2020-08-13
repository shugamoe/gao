#!/bin/bash

for i in data/1000*geno.txt; do
  echo
  POSEQUAL=$(echo `head -n1 $i | egrep -o '='`)

  if [ "$POSEQUAL" = "=" ]; then
    echo "Already added = to the end of first row of $i"
    head -n2 $i
  elif [ "$POSEQUAL" = "" ]; then
    sed -e "1s/$/=/" -i $i
    echo $i now has = on the end 
    head -n2 $i
  fi
  echo
done
