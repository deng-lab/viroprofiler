#!/usr/bin/env python3

import pandas as pd
import click


@click.command()
@click.option("--fin", '-i', help="annotation_eggnog.tsv")
@click.option("--out", '-o', help="output.tsv")
def main(fin, out):
    clms = ['query', 'seed_ortholog', 'evalue', 'score', 'eggNOG_OGs',
       'max_annot_lvl', 'COG_category', 'Description', 'Preferred_name', 'GOs',
       'EC', 'KEGG_ko', 'KEGG_Pathway', 'KEGG_Module', 'KEGG_Reaction',
       'KEGG_rclass', 'BRITE', 'KEGG_TC', 'CAZy', 'BiGG_Reaction', 'PFAMs']
    df = pd.read_csv(fin, sep='\t', names=clms, comment='#')
    df.to_csv(out, sep='\t', index=False)


if __name__ == '__main__':
    main()
