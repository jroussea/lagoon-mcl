#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
library(tidyr)

MainFunction <- function() {
   
   args <- commandArgs(TRUE)
   
   path_classification = as.character(args[1])
   
   classification <- read.table(path_classification, sep = ",", 
                                col.names = c("class", 
                                              "architecture", 
                                              "topology", 
                                              "superfamily", 
                                              "sequence_id"))
   
   classification$class <- as.character(classification$class)
   classification$architecture <- as.character(classification$architecture)
   
   cath_class <- classification %>% 
      group_by(class) %>% 
      summarise(num_class = n()) 
   cath_architecture <- classification %>% 
      group_by(architecture) %>% 
      summarise(num_architecture = n()) 
   cath_topology <- classification %>% 
      group_by(topology) %>% 
      summarise(num_topology = n())
   cath_superfamily <- classification %>% 
      group_by(superfamily) %>% 
      summarise(num_superfamily = n())
   
   classification <- merge(classification, cath_class, by = "class")
   classification <- merge(classification, cath_architecture, by = "architecture")
   classification <- merge(classification, cath_topology, by = "topology")
   classification <- merge(classification, cath_superfamily, by = "superfamily")
   
   write.table(classification, "classification.tsv", sep = "\t", 
               row.names = FALSE, col.names = TRUE)
}


if(!interactive()) {
   MainFunction()
}