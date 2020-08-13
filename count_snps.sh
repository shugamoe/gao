#!/bin/bash

for i in data/*snpinfo.txt*; do
  echo 
  echo $i
  SNP=$((`cut -f 2 --delimiter=' ' $i | sort -u | wc -l` - 1))
  PREFIX=`echo $i | sed -e 's/_snpinfo.txt//g'`
  echo $PREFIX has $SNP SNPs
  GENO=$PREFIX.geno.txt
  sed -i -e "2s/.*/$SNP/" $GENO
  echo First 2 Lines of: $GENO
  head -n2 $GENO
  echo
done
