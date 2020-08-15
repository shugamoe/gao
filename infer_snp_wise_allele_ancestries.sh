#!/bin/bash

# 1) Run the ELAI to infer SNP-wise allele ancestries

elai -g data/1000CEU_Chr21.geno.txt -p 10 \
  -g data/1000YRI_Chr21.geno.txt -p 11 \
  -g data/CancerChr21.geno.txt -p 1 \ 
  -pos data/CancerChr21.pos.txt -s 30 -C 2 -c 10 \
  -o Adm_Cancer_Chr21 -mixgen 10 --exclude-nopos --exclude-miss1
elai -g data/1000CEU_Chr22.geno.txt -p 10 \
  -g data/1000YRI_Chr22.geno.txt -p 11 \
  -g data/CancerChr22.geno.txt -p 1 \
  -pos data/CancerChr22.pos.txt -s 30 -C 2 -c 10 \
  -o Adm_Cancer_Chr22 -mixgen 10 --exclude-nopos --exclude-miss1

# CEU = European | YRI = African
