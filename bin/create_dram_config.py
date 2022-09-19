#!/usr/bin/env python

import click
import os
from pathlib import Path
import json
from datetime import date


@click.command()
@click.option("--db", '-d', help="Database path", required=True)
def main(db):
    # create db path if not exists
    db = os.path.abspath(db)
    os.makedirs(db, exist_ok=True)

    # get today's date
    today = date.today().strftime("%Y%m%d")

    cfg = {"kofam": "kofam_profiles.hmm","kofam_ko_list": "kofam_ko_list.tsv","pfam": "pfam.mmspro","dbcan": "dbCAN-HMMdb-V10.txt","viral": "refseq_viral.mmsdb","peptidase": "peptidases.mmsdb","vogdb": "vog_latest_hmms.txt","pfam_hmm_dat": "Pfam-A.hmm.dat.gz","dbcan_fam_activities": "CAZyDB.07292021.fam-activities.txt","vog_annotations": "vog_annotations_latest.tsv.gz","genome_summary_form": "genome_summary_form.tsv","module_step_form": "module_step_form.tsv","etc_module_database": "etc_mdoule_database.tsv","function_heatmap_form": "function_heatmap_form.tsv","amg_database": "amg_database.tsv","description_db": "description_db.sqlite"}

    # add download date
    cfg["viral"] = f"refseq_viral.{today}.mmsdb"
    cfg["peptidase"] = f"peptidases.{today}.mmsdb"
    cfg["genome_summary_form"] = f"genome_summary_form.{today}.tsv"
    cfg["module_step_form"] = f"module_step_form.{today}.tsv"
    cfg["etc_module_database"] = f"etc_mdoule_database.{today}.tsv"
    cfg["function_heatmap_form"] = f"function_heatmap_form.{today}.tsv"
    cfg["amg_database"] = f"amg_database.{today}.tsv"

    # add db path
    cfg = {x:os.path.join(db, cfg[x]) for x in cfg.keys()}
    cfg['uniref'] = "null"

    # convert dict to string
    cfg_str = json.dumps(cfg)
    cfg_str = cfg_str.replace('"null"', "null")

    # save config file
    with open(os.path.join(db, "CONFIG"), "w") as f:
        f.write(cfg_str+"\n")


if __name__ == '__main__':
    main()