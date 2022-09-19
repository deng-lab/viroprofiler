#!/usr/bin/env python

import click
import pandas as pd
from collections import OrderedDict


def format_mmseqs_taxa(x, unclassified, col_lineage="lineage", dbsource="ICTV"):
    new_row = OrderedDict(x)
    
    # Add taxonomy ranks as new columns
    if dbsource == "ICTV":
        newcols = ['Realm', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
    elif dbsource == "NCBI":
        newcols = ['Domain', 'Kingdom', 'Phylum', 'Class', 'Order',
                'Family', 'Genus', 'Species']
    
    # Init ranks as unclassified (default: unknown)
    for taxa_rank_level in newcols:
        new_row[taxa_rank_level] = unclassified
    
    # Extract taxonomy names to new columns
    lineage = new_row[col_lineage].split(";")
    # if len(lineage) > 9:
    #     # Strain level
    #     print("{}: {}".format(x['contig_id'], x['lineage']))
    #     rank_level, rank_name = lineage[9].split("_", maxsplit=1)
    #     if rank_level == "-":
    #         new_row["Strain"] = rank_name
    #         lineage = lineage[:8]

    for rank in lineage:
        rank_level, rank_name = rank.split("_", maxsplit=1)
        if rank_level == "d":
            new_row["Domain"] = rank_name
        # elif rank_level == "-":
        #     new_row["Realm"] = rank_name
        elif rank_level == "k":
            new_row["Kingdom"] = rank_name
        elif rank_level == "p":
            new_row["Phylum"] = rank_name
        elif rank_level == "c":
            new_row["Class"] = rank_name
        elif rank_level == "o":
            new_row["Order"] = rank_name
        elif rank_level == "f":
            new_row["Family"] = rank_name
        elif rank_level == "g":
            new_row["Genus"] = rank_name
        elif rank_level == "s":
            new_row["Species"] = rank_name

    # Delete col_lineage
    del new_row[col_lineage]
    return new_row


@click.command()
@click.option("--fin", '-i', help="input file name")
@click.option("--fout_prefix", '-o', default='taxa_mmseqs', help="output file name")
@click.option("--unclassified", '-u', default='unknown', help="Unclassified contig taxa")
@click.option("--dbsource", '-s', default='ICTV', help="ICTV or NCBI")
def main(fin, fout_prefix, unclassified, dbsource):
    cols = ["contig_id", "taxa_id", "lca_rank", "lca_name", "nprot_all", "nprot_labeled", "nprot_support", "pctprot_support", "lineage"]
    df = pd.read_csv(fin, sep="\t", names=cols)

    # Remove unclassified contigs
    df = df[~df.lineage.isna()]
    
    # Format taxonomy ranks
    formatted_taxa = df.apply(lambda x: format_mmseqs_taxa(x, unclassified, col_lineage="lineage", dbsource=dbsource), axis=1)
    df_formatted = pd.DataFrame(list(formatted_taxa))
    
    # save results
    df_formatted.to_csv("{}_formatted_all.tsv".format(fout_prefix), sep="\t", index=False)

    # save selected columns for merging with vConTACT2 clusters
    if dbsource == "ICTV":
        df_sel = df_formatted[['contig_id', 'Realm', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species', 'Strain']]
    elif dbsource == "NCBI":
        df_sel = df_formatted[['contig_id', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']]
    df_sel.to_csv('{}.tsv'.format(fout_prefix), sep="\t", index=False)
    return df_formatted


if __name__ == '__main__':
    main()
