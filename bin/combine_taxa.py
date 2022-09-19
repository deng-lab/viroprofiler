#!/usr/bin/env python

import click
import pandas as pd


@click.command()
@click.option("--fvcontact", '-c', help="input file name")
@click.option("--fmmseqs", '-m', help="input file name")
@click.option("--fout_prefix", '-o', default='taxa', help="output file name")
def main(fvcontact, fmmseqs, fout_prefix):
    vcontact = pd.read_csv(fvcontact, sep="\t")
    mmseqs = pd.read_csv(fmmseqs, sep="\t")
    
    # Rename vcontact taxa columns
    vc_taxa_cols = ['Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus']
    vcontact.rename(columns={x: 'vc_{}'.format(x) for x in vc_taxa_cols}, inplace=True)
    
    # Merge mmseqs and vcontact taxonomy
    rst = mmseqs.merge(vcontact, on='contig_id', how='outer')
    
    # Annotated by both vcontact and mmseqs
    rst_anno_both = rst[~(rst.Kingdom.isna()) & ~(rst.vc_Kingdom.isna())]
    
    # export
    rst.to_csv('{}.tsv'.format(fout_prefix), sep = '\t', index = False)
    rst_anno_both.to_csv('{}_DBagree.tsv'.format(fout_prefix), sep = '\t', index = False)
    


if __name__ == '__main__':
    main()