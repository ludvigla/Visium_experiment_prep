#!/bin/bash
sample=
for file in ${sample}_*_R1_*
do
cat $file >> merged_${sample}_R1.fastq.gz
done
for file in ${sample}_*_R2_*
do
cat $file >> merged_${sample}_R2.fastq.gz
done
