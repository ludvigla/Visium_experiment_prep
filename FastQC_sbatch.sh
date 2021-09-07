#!/bin/bash
#SBATCH -N 1 -n 1 -c 5
#SBATCH --mem 32000
#SBATCH -t 4:00:00
#SBATCH -J 
#SBATCH --mail-user
#SBATCH --mail-type=ALL
#SBATCH -e job-%J.err
#SBATCH -o job-%J.out

/home/ludvig.larsson/FastQC/fastqc 
