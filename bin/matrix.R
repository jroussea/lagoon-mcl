#!/usr/bin/env Rscript

library(dplyr)
library(argparse)

MainFunction <- function() {
   
   parser <- ArgumentParser()
   
   parser$add_argument("-n", "--network", type="character", help="")
   
   parser$add_argument("-l", "--label", type="character", help="")
   
   args <- parser$parse_args()
   
   network <- read.table(args$network, sep = "\t", header = FALSE, 
                         col.names = c("cluster_id", "protein_accession", 
                                       "inflation"))
   label <- read.table(args$label, sep = "\t", header = FALSE, 
                       col.names = c("protein_accession", "database_accession", 
                                     "database"))
   
   network.label <- merge(network, label, by = "protein_accession")
   
   network.label.matrix <- network.label |> 
      select(cluster_id, database_accession) |> 
      group_by(cluster_id, database_accession) |> 
      summarise(count = n())
   
   
   print(head(network.label.matrix))
   
   write.table(network.label.matrix, "matrix_preparation", sep = "\t", col.names = FALSE, row.names = FALSE, quote = FALSE)
}

if(!interactive()) {
   MainFunction()
}
