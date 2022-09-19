#!/usr/bin/env bash
# Usage: mask_genome.sh ref.fna.gz viral.fna.gz ref_mask.fna.gz 0.9 8

set -eu
echo "Start..."

TARGET_GENOME=$1
MASK_SOURCE=$2
FOUT=$3
ENTROPY=$4
THREADS=$5
MEM=$6

shred.sh in=$MASK_SOURCE out=tmp_shredded.fa length=80 minlength=70 overlap=40
bbmap.sh -Xmx$MEM ref=$TARGET_GENOME in=tmp_shredded.fa outm=tmp_mapped.sam minid=0.85 maxindel=2 t=$THREADS
bbmask.sh -Xmx$MEM in=$TARGET_GENOME out=tmp_out.fna.gz entropy=$ENTROPY sam=tmp_mapped.sam t=$THREADS
seqkit -is replace -p "N" -r "" tmp_out.fna.gz | pigz -p $THREADS > $FOUT
rm tmp_out.fna.gz tmp_shredded.fa
