#!/usr/bin/env Rscript

library(dplyr)

MainFunction <- function() {
   args <- commandArgs(TRUE)
   
   annotation <- read.table(as.character(args[1]), header = FALSE, sep = "\t")
   
   database <- as.character(args[2])
   
   annotation["database"] <- database
   
   colnames(annotation) <- c("protein_accession", "database_accession",
                             "database")
   
   name = paste(database, ".tsv", sep = "")
   
   write.table(annotation,name , sep = "\t", 
               row.names = FALSE, col.names = TRUE, quote = FALSE)
}


if(!interactive()) {
   MainFunction()
}