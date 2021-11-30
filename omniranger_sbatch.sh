#!/bin/bash
#SBATCH -N 1 -n 1 -c 15
#SBATCH --mem 64000
#SBATCH -t 12:00:00
#SBATCH -J 
#SBATCH --mail-user
#SBATCH --mail-type=ALL
#SBATCH -e job-%J.err
#SBATCH -o job-%J.out

FASTQ=
SAMPLEID=
JPEG=
AREA=
REF=

# Run spaceranger
omniranger count --id=$SAMPLEID \
--fastqs=$FASTQ \
--transcriptome=$REF \
--sample=$SAMPLEID \
--image=$JPEG \
--unknown-slide
