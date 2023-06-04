#!/usr/bin/env python

import click
import pandas as pd


def read_coverm(fin):
    df = pd.read_csv(fin, sep="\t")
    # set the column "Contig" as the index
    df.set_index("Contig", inplace=True)
    return df


@click.command()
@click.option("--fin_abundance", '-a', help="Abundance file")
@click.option("--fin_covfrac", '-c', help="Coverage fraction file")
@click.option("--fout", '-o', default='abundance_normalized.tsv', help="output file name, ends with .gz for compressed file")
@click.option("--covfrac_cutoff", '-t', default=0.7, help="coverage fraction cutoff")
@click.option("--reads_length", '-l', default=150, help="length of reads")
@click.option("--inflation", '-i', default=1, help="inflation factor")
def main(fin_abundance, fin_covfrac, fout, covfrac_cutoff, reads_length, inflation):
    df_abundance = read_coverm(fin_abundance)
    df_covfrac = read_coverm(fin_covfrac)
    
    # normalize coverage fraction: set value to 0 if they are less than the cutoff, otherwise set to 1
    df_covfrac = df_covfrac.applymap(lambda x: 0 if x < covfrac_cutoff else 1)

    # multiply the abundance by the normalized coverage fraction
    df_abundance_normalized = df_abundance * df_covfrac

    # normalize the abundance by the length of the reads and the inflation factor
    df_abundance_final = df_abundance_normalized * reads_length * inflation

    # write the output file, if fout ends with .gz, then it will be compressed, otherwise it will be a text file
    df_abundance_final.to_csv(fout, sep="\t", compression='gzip' if fout.endswith('.gz') else None)


if __name__ == '__main__':
    main()
