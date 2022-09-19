#!/bin/bash

set -eu

contamref_genome=$1
viral_refseq=$2
contamref_entropy=$3
ncpus=$4
memory=$5   # 100G


mask_genome.sh $contamref_genome $viral_refseq vir_masked_contam_ref.fna.gz $contamref_entropy $ncpus $memory
rm -rf ref
bbmap.sh -Xmx$memory ref=vir_masked_contam_ref.fna.gz threads=$ncpus
