#!/bin/bash
sample=
for file in ${sample}_*_R1_*
do
cat $file >> merged_${sample}_L001_R1_001.fastq.gz
done
for file in ${sample}_*_R2_*
do
cat $file >> merged_${sample}_L001_R2_001.fastq.gz
done
