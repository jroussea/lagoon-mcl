#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
library(tidyr)

MainFunction <- function() {
  
  args <- commandArgs(TRUE)
  path_network <- args[1]
  inflation <- args[2]
  filtration <- args[3]
  
  network = read.table(path_network, sep = "\t", header = TRUE)
  
  columns <- colnames(network)
  columns <- columns[-1]
  
  network <- network %>% 
    pivot_longer(cols = columns,
                 names_to = "sert",
                 values_to = "darkdino_sequence_id") %>% 
    select(-sert) %>% 
    drop_na()
    
  #inflation <- strsplit(path_network, split = ".", fixed = T)
  
  #inflation <- unlist(inflation)
  
  file_name <- paste("network_", inflation, "_", filtration, ".tsv", 
                     sep = "", collapse = NULL)
  
  write.table(network, file_name, row.names = FALSE, sep = "\t")
}


if(!interactive()) {
  MainFunction()
}