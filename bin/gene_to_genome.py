#!/usr/bin/env python

from Bio import SeqIO
import pandas as pd
import click

@click.command()
@click.option("--faa", '-a', help="Protein FASTA file name.")
@click.option("--out", '-o', help="Gene to genome file.")
def gene_to_genome_file(faa, out):
    gene2genome = []
    for record in SeqIO.parse(faa, "fasta"):
        rcid_list = record.id.split('_')
        ctg_id = '_'.join(rcid_list[:-1])
        if '__' in record.id:
            sample_id = record.id.split('__')[0]
        else:
            sample_id = record.id.split('_')[0]

        gene2genome.append([record.id, ctg_id, sample_id])
    
    tbl = pd.DataFrame(gene2genome, columns=['protein_id', 'contig_id', 'keywords'])
    tbl.to_csv(out, index=False, sep='\t')

if __name__ == '__main__':
    gene_to_genome_file()
