#!/usr/bin/env python

from Bio import SeqIO
import click

@click.command()
@click.option("--fasta", '-i', help="Gene or protein FASTA file")
@click.option("--ctg", '-c', help="Contig list file name")
@click.option("--out", '-o', help="Extracted gene or protein FASTA file.")
@click.option('--reverse', '-r', is_flag=False, help="Extract sequence not in contig list.")
def main(fasta, ctg, out, reverse):
    with open(ctg, 'r') as fh:
        ctg_list = fh.read().splitlines()
        
    records = []
    for record in SeqIO.parse(fasta, "fasta"):
        ctg_id = '_'.join(record.id.split('_')[:-1])
        if reverse:
            if ctg_id not in ctg_list:
                records.append(record)
        else:
            if ctg_id in ctg_list:
                records.append(record)
            
    SeqIO.write(records, out, "fasta")

if __name__ == '__main__':
    main()