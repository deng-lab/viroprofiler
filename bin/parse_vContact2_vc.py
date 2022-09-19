#!/usr/bin/env python

import pandas as pd
import numpy as np
import click


def add_overlap_vc(x):
    if x["VC Status"].startswith('Overlap ('):
        vc = x["VC Status"].replace("Overlap (", "").replace(")", "")
    else:
        vc = x["VC"]
    return vc


def find_lca(df):
    cols = ['Genus', 'Family', 'Order', 'Class', 'Phylum', 'Kingdom']
    for col in cols:
        if df[col].nunique() != 1:
            df[col] = np.nan
        else:
            break
    return df


def ref_lca(df_vc_ref):
    dfs = []
    for vc in df_vc_ref.VC.unique():
        tbl = df_vc_ref[df_vc_ref.VC==vc].copy()
        tbl_lca = find_lca(tbl)
        tbl_lca.drop_duplicates(inplace=True)
        dfs.append(tbl_lca)
    return pd.concat(dfs)


@click.command()
@click.option("--fin", '-i', help="genome_by_genome_overview.csv")
@click.option("--fout_prefix", '-o', help="taxa_pred_vc")
@click.option("--assembler", '-a', default='spades', help="spades, megahit, ...")
def main(fin, fout_prefix, assembler):
    # Currently only works for spades
    if assembler == "spades":
        # All spades contig names contain "Node_"
        assembler_id = "NODE_"
    elif assembler == "other":
        # All vConTACT2 reference genome names contain "~"
        assembler_id = "~"

    df = pd.read_csv(fin)
    # Remove "singleton" and "Outlier" since they have no VC information
    df = df[~df["VC Status"].isin(["Singleton", "Outlier"])]

    # Add "Overlap (VC1/VC2)" to the VC column
    df['VC'] = df.apply(lambda x: add_overlap_vc(x), axis=1)

    # Replace "Unassigned" with NA
    df.replace('Unassigned', np.nan, inplace=True)

    # query contigs: VC, contig_id
    if assembler == "other":
        df_vc_qry = df[~df['Genome'].str.contains(assembler_id)][['Genome', 'VC']].copy()
    else:
        df_vc_qry = df[df['Genome'].str.contains(assembler_id)][['Genome', 'VC']].copy()
    df_vc_qry.rename(columns={'Genome':'contig_id'}, inplace=True)
    # print(df_vc_qry.shape)

    # ref genomes: VC, taxonomy ranks (Kingdom -> Genus)
    if assembler == "other":
        df_ref = df[df['Genome'].str.contains(assembler_id)][['VC', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus']].copy()
    else:
        df_ref = df[~df['Genome'].str.contains(assembler_id)][['VC', 'Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus']].copy()
    df_ref.drop_duplicates(inplace=True)
    df_ref_lca = ref_lca(df_ref)

    # Add ref taxonomy to query contigs
    df_vc_qry_anno = df_vc_qry.merge(df_ref_lca, on='VC', how='left').copy()
    print(df_vc_qry_anno.shape)

    # Sort contigs and Genus so that NA annotations will be at the bottom of each VC
    df_vc_qry_anno.sort_values(['contig_id', 'Genus'], ascending=False, inplace=True)

    # For contigs have multiple VC Genus, randomly select one, so that there are no duplicated contigs in the table
    df_rst = df_vc_qry_anno.drop_duplicates("contig_id").sort_values(['Kingdom', 'VC']).reset_index(drop=True)

    # Save 
    df_ref.to_csv("{}_ref.tsv".format(fout_prefix), sep='\t', index=False)
    df_rst.to_csv("{}.tsv".format(fout_prefix), sep='\t', index=False)


if __name__ == '__main__':
    main()
