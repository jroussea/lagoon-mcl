#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(magrittr)


LoadData <- function() {
  
  args <- commandArgs(TRUE)
  
  return_list <- list(path_homogeneity_score = as.character(args[1]),
                      inflation = as.character(args[2]),
                      filtration = as.character(args[3]))
  
  #return_list <- list(path_homogeneity_score = "homogeneity_score_annotated_1.4_without_filtration.tsv",
  #                    inflation = "1.4",
  #                    filtration = "without_filtration")
  
  return(return_list)
}


LoadDataframe <- function(path_dataframe) {
  dataframe <- read.table(path_dataframe, sep = "\t", header = TRUE)
  
  return(dataframe)
}


CreationPlots <- function(dataframe, variable) {
  
  x_labs <- gsub("_", " ", variable)
  
  title_labs <- paste("Distribution", x_labs)
  #####
  
  max_hom_score <- dataframe %>% 
    group_by(get(variable)) %>% 
    count() %>% 
    max()
  
  
  count_hom_score <- dataframe %>% 
    filter(get(variable) >= 0.5) %>% 
    group_by(get(variable)) %>% 
    count() 
  
  min_hom_score <- sum(count_hom_score$n)
  
  ####
  graph <- dataframe %>%
    ggplot(aes(x = dataframe[,variable])) +
    geom_histogram(bins = 50, color = "darkblue", fill = "lightblue") +
    theme_light() +
    labs(title = title_labs,
         x = x_labs,
         y = "Count") +
    theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
          axis.title = element_text(size = 14),
          axis.text = element_text(size = 12))
  
  
  zoom <- dataframe %>% 
    ggplot(aes(x = dataframe[,variable])) +
    geom_histogram(bins = 50, color = "darkblue", fill = "lightblue") +
    theme_light() +
    xlim(0.5, 1) +
    labs(x = x_labs,
         y = "Count")
  
  graph <- graph + annotation_custom(ggplotGrob(zoom), xmin = 0.1, 
                                     xmax = 1, ymin = min_hom_score, 
                                     ymax = max_hom_score) +
    geom_rect(aes(xmin = 0.1, xmax = 1, ymin = min_hom_score, 
                  ymax = max_hom_score), color='black', linetype='dashed', 
              alpha=0) +
    geom_path(aes(x, y, group = grp), 
              data = data.frame(x = c(0.5,0.1,1,1), 
                                y=c(0,min_hom_score,0,min_hom_score),
                                grp=c(1,1,2,2)),
              linetype='dashed')
  
  
  return(graph)
}


MainFunction <- function() {
  args <- LoadData()
  
  homogeneity_score <- LoadDataframe(args$path_homogeneity_score)
  
  columns_homogeneity_score <- colnames(homogeneity_score)
  
  columns_homogeneity_score <- columns_homogeneity_score[-c(1,2)]
  
  pdf(file = paste("distribution_homogeneity_score_", args$inflation, "_", args$filtration, ".pdf"), onefile = TRUE)
  
  lapply(columns_homogeneity_score,
         function(variable){
           graph <- CreationPlots(homogeneity_score, variable)
           print(graph)
         })
  
  dev.off()
}


if(!interactive()) {
  MainFunction()
}
