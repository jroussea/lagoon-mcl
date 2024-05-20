#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(magrittr)


LoadData <- function() {
  
  args <- commandArgs(TRUE)
  
  return_list <- list(path_homogeneity_score = as.character(args[1]),
                      inflation = as.character(args[2]),
                      label = as.character(args[3]),
                      characteristic = as.character(args[4]))
  
  #return_list <- list(path_homogeneity_score = "homogeneity_score_label_Pfam_I1.4_all.tsv",
  #                    inflation = "1.4",
  #                    label = "label_Pfam",
  #                    characteristic = "all")
  
  return(return_list)
}


LoadDataframe <- function(path_dataframe) {
  dataframe <- read.table(path_dataframe, sep = "\t", header = TRUE)
  
  return(dataframe)
}


CreationPlots <- function(dataframe_input, inflation, label) {
  
  x_labs <- gsub("_", " ", label)
  
  title_labs <- paste("Distribution", x_labs, "- Inflation: ", inflation)
  
  dataframe <- dataframe_input %>% 
    filter(homogeneity_score != "unannotated")
  
  graph <- dataframe %>%
    ggplot(aes(x = as.numeric(homogeneity_score))) +
    geom_histogram(bins = 100, color = "darkblue", fill = "lightblue") +
    theme_light() +
    labs(title = title_labs,
         x = x_labs,
         y = "Number of clusters") +
    theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
          axis.title = element_text(size = 14),
          axis.text = element_text(size = 12))
  
  plot_list = list(graph = graph)
  return(plot_list)
}


MainFunction <- function() {
  args <- LoadData()
  
  df_homogeneity_score <- LoadDataframe(args$path_homogeneity_score)
  
  pdf(file = paste("distribution_homogeneity_score_", args$label, "_I",
                   args$inflation, "_", args$characteristic, ".pdf"), 
      onefile = TRUE)
  
  plot_list <- CreationPlots(df_homogeneity_score, args$inflation, args$label)
  print(plot_list$graph)

  dev.off()
}


if(!interactive()) {
  MainFunction()
}
