#!/bin/bash -eu

contigs=$1
minlen_contig=$2
dirout=$3
cpus=$4
assembler=$5  # spades|bin|...
db=$6
wd=$(pwd)

checkv end_to_end $contigs $dirout -t $cpus -d $db
cd $dirout
csvtk grep -v -t -f "provirus" -p "Yes" quality_summary.tsv > quality_summary_viruses.tsv
csvtk grep -t -f "provirus" -p "Yes" quality_summary.tsv >> quality_summary_proviruses.tsv
seqkit seq -g -m $minlen_contig proviruses.fna | seqkit replace -p '_[1-9] .*' -r '' | seqkit rename > proviruses2.fna
seqkit seq -g -M $minlen_contig proviruses.fna > proviruses_short.fna
seqkit fx2tab --name proviruses2.fna >> proviruse_ids_raw.list
if [ -s proviruses2.fna ] ; then
    correct_spades_contig_length.py -i proviruses2.fna -o proviruses_nextInput.fna -a $assembler
    seqkit fx2tab --name proviruses_nextInput.fna >> proviruse_ids_clean.list
else
    ln -s proviruses2.fna proviruses_nextInput.fna
    touch proviruse_ids_clean.list
fi
cd $wd
