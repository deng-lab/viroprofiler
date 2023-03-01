#!/usr/bin/env Rscript

library(argparser)
library(TreeSummarizedExperiment)
library(vpfkit)

p <- arg_parser("Create ViroProfiler TSE object")
p <- add_argument(p, "--fin_abcount", help="abundance_contigs_count.tsv.gz")
p <- add_argument(p, "--fin_abtpm", help="abundance_contigs_tpm.tsv.gz")
p <- add_argument(p, "--fin_abcov", help="abundance_contigs_covered_fraction.tsv.gz")
p <- add_argument(p, "--fin_taxa", help="taxa_mmseqs_formatted_all.tsv")
p <- add_argument(p, "--fin_checkv", help="quality_summary.tsv")
p <- add_argument(p, "--fin_virsorter2", help="final-viral-score.tsv")
p <- add_argument(p, "--fin_vibrant", help="VIBRANT_genome_quality_contigs.tsv")
p <- add_argument(p, "--fin_dvf", help="dvf_virus.tsv")
p <- add_argument(p, "--fin_replicyc", help="putative_vcontigs_pref1.fasta.bacphlip")
argv <- parse_args(p)

tse <- vpfkit::create_vpftse(fin_abcount = argv$fin_abcount,
                      fin_abtpm = argv$fin_abtpm,
                      fin_abcov = argv$fin_abcov,
                      fin_taxa = argv$fin_taxa,
                      fin_checkv = argv$fin_checkv,
                      fin_virsorter2 = argv$fin_virsorter2,
                      fin_vibrant = argv$fin_vibrant,
                      fin_dvf = argv$fin_dvf,
                      fin_replicyc = argv$fin_replicyc)

tse_vir <- vpfkit::create_vpftse_vir(tse)

readr::write_rds(tse, file = "viroprofiler_output_all_contigs.rds")
readr::write_rds(tse_vir, file = "viroprofiler_output.rds")

