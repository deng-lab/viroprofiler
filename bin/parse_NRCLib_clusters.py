#!/usr/bin/env python

# Usage: parse_NRCLib_clusters.py -i cluster.clstr -o cluster.tsv [-m mummer]
#    or: parse_NRCLib_clusters.py -i ctg_clusters.tsv -o cluster.tsv -m ani

import pandas as pd
import click
import re

def parse_mummer(fn_clstr):
    with open(fn_clstr, 'r') as fh:
        f = fh.read().splitlines()
        f = [re.sub(r'\s+', ' ', x) for x in f if not x.startswith("##")]
    
    entries_all = []
    for row in f:
        cols = row.split(' ')
        if row.startswith('>'):
            repid = cols[1]
            entries_all.append([repid, repid])
        else:
            ctgid = cols[0]
            entries_all.append([repid, ctgid])
    return entries_all


def parse_ani(fn_clstr):
    with open(fn_clstr, "r") as fh:
        f = fh.read().splitlines()
    entries_all = [[x.split('\t')[0], member] for x in f for member in x.split('\t')[1].split(',')]
    return entries_all


@click.command()
@click.option("--fn_clstr", '-i', help="Cluster_genomes_5.1.pl clstr output")
@click.option("--out", '-o', help="virsorter.tsv")
@click.option("--method", '-m', default="mummer", help="mummer|ani")
def main(fn_clstr, out, method):
    if method == "mummer":
        entries_all = parse_mummer(fn_clstr)
    elif method == "ani":
        entries_all = parse_ani(fn_clstr)

    df = pd.DataFrame(entries_all, columns=['repid', 'ctgid'])
    df.to_csv(out, index=False, sep='\t')
    

if __name__ == '__main__':
    main()
