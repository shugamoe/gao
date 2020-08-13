#!/bin/bash

# 1) Extract and save autosome-wise bim, fam, and bed files (done by Gao)

# 2) Convert the above files to ped and map files

plink1.9 --bfile data/CIDR_Olopade_Plus_hg19_3686subject_chr21 --recode --out data/CIDR_Olopade_Plus_hg19_3686subject_chr21_new --noweb # Chromosome 21
plink1.9 --bfile data/CIDR_Olopade_Plus_hg19_3686subject_chr22 --recode --out data/CIDR_Olopade_Plus_hg19_3686subject_chr22_new --noweb # Chromosome 21

# 3) Convert the ped and map files to a bimbam file

fcgene --file data/CIDR_Olopade_Plus_hg19_3686subject_chr21_new --oformat bimbam --out data/CancerChr21
fcgene --file data/CIDR_Olopade_Plus_hg19_3686subject_chr22_new --oformat bimbam --out data/CancerChr22


