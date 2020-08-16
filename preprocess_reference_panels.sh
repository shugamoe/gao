#!/bin/bash

# 1) Convert the vcf file from reference panel to a bed file
plink1.9 --vcf data/chr21.phase1_release_v3.20101123.snps_indels_svs.genotypes.refpanel.EUR.vcf  --make-bed --out data/EUR_Chr21
plink1.9 --vcf data/chr22.phase1_release_v3.20101123.snps_indels_svs.genotypes.refpanel.EUR.vcf  --make-bed --out data/EUR_Chr22
plink1.9 --vcf data/chr21.phase1_release_v3.20101123.snps_indels_svs.genotypes.refpanel.AFR.vcf  --make-bed --out data/AFR_Chr21
plink1.9 --vcf data/chr22.phase1_release_v3.20101123.snps_indels_svs.genotypes.refpanel.AFR.vcf  --make-bed --out data/AFR_Chr22
#
# 2) Extract YRI and CEU data from AFR and EUR and save the data to ped and map files
# EUR goes with CEU, YRI with EUR.
# Keeping these people from the International Hap Map Project
# YRI are 30 adult-and-both-parents Yoruba trios from Nigeria
# CEU are 30 trios of Utah residents of northern and western European ancestry.
plink1.9 --bfile data/AFR_Chr21 --keep data/YRI_ID.txt --recode --out data/1000YRI_Chr21
plink1.9 --bfile data/AFR_Chr22 --keep data/YRI_ID.txt --recode --out data/1000YRI_Chr22

plink1.9 --bfile data/EUR_Chr21 --keep data/CEU_ID.txt --recode --out data/1000CEU_Chr21
plink1.9 --bfile data/EUR_Chr22 --keep data/CEU_ID.txt --recode --out data/1000CEU_Chr22

# 3) Remove non-rs SNPs from the reference panels
plink1.9 --file data/1000YRI_Chr21 --exclude data/1000YRI_Chr21_Delete.txt --recode --out data/1000YRI_Chr21_update --noweb
plink1.9 --file data/1000YRI_Chr22 --exclude data/1000YRI_Chr22_Delete.txt --recode --out data/1000YRI_Chr22_update --noweb

plink1.9 --file data/1000CEU_Chr21 --exclude data/1000CEU_Chr21_Delete.txt --recode --out data/1000CEU_Chr21_update --noweb
plink1.9 --file data/1000CEU_Chr22 --exclude data/1000CEU_Chr22_Delete.txt --recode --out data/1000CEU_Chr22_update --noweb

# 4) Convert reference ped and map files to a bimbam file
fcgene --file data/1000YRI_Chr21_update --oformat bimbam --out data/1000YRI_Chr21
fcgene --file data/1000YRI_Chr22_update --oformat bimbam --out data/1000YRI_Chr22

fcgene --file data/1000CEU_Chr21_update --oformat bimbam --out data/1000CEU_Chr21
fcgene --file data/1000CEU_Chr22_update --oformat bimbam --out data/1000CEU_Chr22

# 5) Modify each bimbam genotype file to the ELAI format
# 5.1) For the study data, only replace the “0” on the second row with the number of SNPS of
# the chromosome. 
# JCM: Can do it with plink, bash script also possible.

# plink1.9 --file data/CIDR_Olopade_Plus_hg19_3686subject_chr21_new --recode bimbam --out data/CancerChr21
# plink1.9 --file data/CIDR_Olopade_Plus_hg19_3686subject_chr22_new --recode bimbam --out data/CancerChr22
./count_snps.sh

# 5.2) For a reference file, add “=” immediately after the number of reference haplotypes on
# the first row, and then replace the “0” on the second row with the number of SNPS of
# the chromosome
./mod_ref_files.sh

# 6) Modify the study bimbam position file to the ELAI format
# Add “,” and the chromosome ID after the position number on each row. You may generate
# csv file to add comma and save it as the txt file
#
# Only the position file of the study data will be needed to run ELAI. The reference position files
# will not be needed.
./mod_pos_files.sh

