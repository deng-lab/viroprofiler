#!/usr/bin/env python

# Usage: pretty_gff.py -i in.gff -o out.gff

import click
import re

@click.command()
@click.option("--fin", '-i', help="in.gff")
@click.option("--out", '-o', help="output.gff")
def modify_gff(fin, out):
    with open(fin, 'r') as fh:
        f = fh.read().splitlines()
    
    fclean = [x for x in f if x[0]!='#']
    gff_new = [f[0]]
    for item in fclean:
        entry = item.split('\t')
        ctgid = entry[0]
        desc = entry[8]
        desc_list = desc.split(';')
        desc_list[0] = re.sub(r'^ID=[0-9]*_', 'ID={}_'.format(ctgid), desc_list[0])
        # desc_list[0] = desc_list[0].replace('ID=','ID={}_'.format(ctgid))
        entry[8] = ';'.join(desc_list)
        item_new = '\t'.join(entry)
        gff_new.append(item_new)
    
    with open(out, 'w') as fh:
        fh.write('\n'.join(gff_new)+'\n')


if __name__ == '__main__':
    modify_gff()
