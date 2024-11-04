#!/usr/bin/env Rscript

MainFunction <- function() {
   args <- commandArgs(TRUE)
   
   network <- read.table(args[1], header = FALSE, col.names = c("protein_accession", "sequence_length"), sep = "\t")
   annotation <- read.table(args[2], header = TRUE, sep = "\t")
   basename <- args[3]
   
   
   df.merge <- merge(network, annotation, by = "protein_accession")
   
   df.length <- df.merge[,c(1,2,4)]
   df.length <- df.length[!duplicated(df.merge), ]
   name.length <- paste(basename, "length_network.tsv", sep = "_")
   # longeur des séquences annoté avec la panque de donnée (dans le réseau)
   write.table(df.length, name.length, col.names = FALSE, row.names = FALSE, 
               quote = FALSE, sep = "\t")
   
   df.annotation <- df.merge[,c(1,3,4)]
   # annotation des séquences (dans le réseau)
   name.annotation <- paste(basename, "annotation_network.tsv", sep = "_")
   write.table(df.annotation, name.annotation, col.names = FALSE, row.names = FALSE, 
               quote = FALSE, sep = "\t")
}


if(!interactive()) {
   MainFunction()
}