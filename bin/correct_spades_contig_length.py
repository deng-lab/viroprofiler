#!/usr/bin/env python

import click
import re
from Bio import SeqIO

def replace_seq_length(rec):
    rec_len = len(rec.seq)
    new_id = re.sub("_length_(\d+)_cov_", "_length_"+str(rec_len)+"_cov_", rec.id)
    rec.id = new_id
    rec.name = new_id
    rec.description = ""
    return rec

@click.command()
@click.option("--fin", '-i', help="contigs.fna")
@click.option("--fout", '-o', help="contigs_new.fna")
@click.option("--assembler", '-a', default="spades", help="spades|bin")
def main(fin, fout, assembler="spades"):
    with open(fout, "w") as fh:
        for rec in SeqIO.parse(fin,'fasta'):
            if assembler=="spades":
                rec = replace_seq_length(rec)
            SeqIO.write(rec, fh, "fasta")


if __name__ == '__main__':
    """
    Replace spades assembly header with correct sequence length.
    For example, there is a prophage in contig,
    `Wizard__NODE_109_length_21434_cov_2.143004`.
    After removing bacteria host region, the new phage contig should be,
    `Wizard__NODE_109_length_10349_cov_2.143004`.
    """
    main()