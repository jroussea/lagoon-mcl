#!/usr/bin/env Rscript

MainFunction <- function() {
   args <- commandArgs(TRUE)
   
   network <- read.table(args[1], header = FALSE, col.names = c("protein_accession", "sequence_length"), sep = "\t")
   annotation <- read.table(args[2], header = TRUE, sep = "\t")
   basename <- args[3]
   
   
   df.merge <- merge(network, annotation, by = "protein_accession")
   
   df.merge <- df.merge[,c(1,2,4)]
   
   name <- paste(basename, "ploufnetwork.tsv", sep = "_")
   
   write.table(df.merge, name, col.names = FALSE, row.names = FALSE, 
               quote = FALSE, sep = "\t")
   
}


if(!interactive()) {
   MainFunction()
}