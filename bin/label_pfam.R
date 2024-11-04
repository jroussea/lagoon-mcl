#!/usr/bin/env Rscript

library(readr)
library(dplyr)


MainFunction <- function() {
   args <- commandArgs(TRUE)
   
   all_pfam <- read_table(as.character(args[1]), col_names = FALSE)
   
   all_pfam_select <- all_pfam |> 
      select(X1, X4)
   
   all_pfam_select["database"] <- "pfam"
   colnames(all_pfam_select) <- c("protein_accession", "database_accession", 
                                  "database")
   
   write.table(all_pfam_select, "pfam", sep = "\t", row.names = FALSE, 
               col.names = TRUE, quote = FALSE)
}


if(!interactive()) {
   MainFunction()
}