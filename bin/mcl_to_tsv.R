#!/usr/bin/env Rscript

library(tidyr)
library(dplyr)

MainFunction <- function() {
  
  args <- commandArgs(TRUE)
  path_network <- args[1]
  
  network = read.table(path_network, sep = "\t", header = TRUE)
  
  columns <- colnames(network)
  columns <- columns[-1]
  
  network <- network %>% 
    pivot_longer(cols = columns,
                 names_to = "sert",
                 values_to = "darkdino_sequence_id") %>% 
    select(-sert) %>% 
    drop_na()
  
  inflation <- strsplit(path_network, split = ".", fixed = T)
  
  inflation <- unlist(inflation)
  
  file_name <- paste("network_", inflation[5], ".tsv", 
                     sep = "", collapse = NULL)
  
  write.table(network, file_name, row.names = FALSE, sep = "\t")
}


if(!interactive()) {
  MainFunction()
}