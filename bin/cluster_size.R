#!/usr/bin/env Rscript

library(dplyr)
library(magrittr)
library(ggplot2)

LoadData <- function() {
  
  args <- commandArgs(TRUE)
  
  return_list <- list(path_network = as.character(args[1]),
                      inflation = as.character(args[2]))
  
  #return_list <- list(path_network = "network_I1.4.tsv",
  #                    inflation = "1.4")
  
  return(return_list)
}


LoadDataframe <- function(path_dataframe) {
  dataframe <- read.table(path_dataframe, sep = "\t", header = TRUE)
  
  return(dataframe)
}


SaveDataframe <- function(dataframe, inflation) {
  
  name = paste("network_I", inflation, "_cluster_size.tsv", sep = "")
  
  write.table(dataframe, name, sep = "\t", row.names = FALSE, col.names = TRUE)
  
}

CreationPlot <- function(cc_size) {
  
  graph <- cc_size %>%
    ggplot(aes(x = CC_size)) +
    geom_histogram(bins = 100, color = "darkblue", fill = "lightblue") +
    theme_light() +
    labs(title = "title_labs",
         x = "x_labs",
         y = "Count") +
    theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
          axis.title = element_text(size = 14),
          axis.text = element_text(size = 12))
  
  return(graph)
  
}


MainFunction <- function() {
  args <- LoadData()
  
  network <- LoadDataframe(args$path_network)
  
  cc_size <- network %>% 
    group_by(CC) %>% 
    count() %>% 
    rename("CC_size" = "n")
  
  pdf(file = paste("distribution_cluster_size_network_I", args$inflation, 
                   ".pdf", sep = ""))
  
  graph <- CreationPlot(cc_size)
  print(graph)
  
  dev.off()
  
  SaveDataframe(cc_size, args$inflation)
}


if(!interactive()) {
  MainFunction()
}