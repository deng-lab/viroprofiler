#!/usr/bin/env python

import click
import pandas as pd
from Bio import SeqIO, Seq
import re


@click.command()
@click.option("--fin", '-i', help="bin FASTA file from vRhyme")
@click.option("--fout_prefix", '-o', help="Prefix of output file")
@click.option("--num_n", '-n', default=11, type=int, help="Number of N to connect contigs in a bin")
def main(fin, fout_prefix, num_n):
    connector = 'N' * num_n
    rcs = list(SeqIO.parse(fin, "fasta"))

    # Generate bin ID and contig IDs from FASTA header
    rc_ids = [x.id for x in rcs]
    ctg_ids = [re.sub("vRhyme_[0-9]*__", "", x) for x in rc_ids]
    bin_id = rc_ids[0].split("__")[0]

    # Generate bin sequence
    ctg_seqs = [str(x.seq) for x in rcs]
    bin_seq = connector.join(ctg_seqs)
    bin_rec = SeqIO.SeqRecord(seq=Seq.Seq(bin_seq), id=bin_id, description="")


    # Save bin FASTA to file
    with open("{}.fasta".format(fout_prefix), "w") as fh:
        SeqIO.write(bin_rec, fh, "fasta")

    # Dataframe of bin_id and contig_id mapping
    df = pd.DataFrame([[bin_id, x] for x in ctg_ids], columns=['bin_id', 'ctg_id'])
    df.to_csv("{}.tsv".format(fout_prefix), sep="\t", index=False)


if __name__ == '__main__':
    main()