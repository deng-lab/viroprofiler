#!/bin/bash

echo "sample,fastq_1,fastq_2" > sample.csv

for f in $(ls fastq/*_R1.fq.gz);do
    fid=$(echo $f | sed 's/_R1.fq.gz//g' | cut -d'/' -f2)
    echo "${fid},$(pwd)/fastq/${fid}_R1.fq.gz,$(pwd)/fastq/${fid}_R2.fq.gz" >> sample.csv
done