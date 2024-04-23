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


CreationPlots <- function(dataframe, inflation, label) {
  
  x_labs <- gsub("_", " ", label)
  
  title_labs <- paste("Distribution", x_labs, "- Inflation: ", inflation)
  
  cc_sup_0 <- dataframe %>% 
    filter(homogeneity_score > 0)
  
  graph <- dataframe %>%
    ggplot(aes(x = homogeneity_score)) +
    geom_histogram(bins = 100, color = "darkblue", fill = "lightblue") +
    theme_light() +
    labs(title = title_labs,
         x = x_labs,
         y = "Count") +
    theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
          axis.title = element_text(size = 14),
          axis.text = element_text(size = 12))

  title_labs <- paste("Distribution", x_labs, "- Inflation: ", inflation)
  
  zoom <- cc_sup_0 %>% 
    ggplot(aes(x = homogeneity_score)) +
    geom_histogram(bins = 100, color = "darkblue", fill = "lightblue") +
    theme_light() +
    labs(title = title_labs,
         subtitle = "Homogeneity score strictly greater than 0",
         x = x_labs,
         y = "Count")+
    theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
          plot.subtitle = element_text(size = 14, face = "italic"),
          axis.title = element_text(size = 14),
          axis.text = element_text(size = 12))
  
  plot_list = list(graph = graph, zoom = zoom)
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
  print(plot_list$zoom)
  
  dev.off()
}


if(!interactive()) {
  MainFunction()
}
