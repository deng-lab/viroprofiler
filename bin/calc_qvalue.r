#!/usr/bin/env Rscript
# usage: calc_qvalue.r dvf_in.tsv 0.01 dvf_out.tsv
library(qvalue)

args = commandArgs(trailingOnly=TRUE)

dvf <- read.table(args[1], header = TRUE)
dvf$qvalue <- qvalue(dvf$pvalue, lambda=0)$qvalues
dvf2 <- dvf[order(dvf$qvalue),]
dvf3 <- dvf2[dvf2$qvalue<args[2],]



# Save results
write.table(dvf3, 
            args[3], quote=FALSE, 
            row.names=FALSE, col.names=TRUE, sep="\t")
