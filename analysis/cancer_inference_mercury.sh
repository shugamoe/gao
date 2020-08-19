#!/bin/bash

#SBATCH --account=pi-ghitsch
#SBATCH --partition=highmem
#SBATCH --job-name=cancer_inference_mercury
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=80g


echo "Job ID: $SLURM_JOB_ID"

module load R/3.6/3.6.2

R --max-ppsize 500000 --no-save  < ./cancer_inference_mercury.R > cancer_inference_mercury.log

echo "cancer_inference_mercury Done"
