#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
library(ggplot2)


MainFunction <- function() {
   args <- commandArgs(TRUE)
   
   database <- as.character(args[2])
   
   dataframe <- read.table(as.character(args[1]), header = FALSE, sep = "\t")
   
   dataframe$V3 <- database
   
   colnames(dataframe) = c("database_accession","sequence_accession","database")
   
   write.table(dataframe, paste(database, ".tsv", sep = ""), sep = "\t", row.names = FALSE, 
               col.names = TRUE, quote = FALSE)
}


if(!interactive()) {
   MainFunction()
}