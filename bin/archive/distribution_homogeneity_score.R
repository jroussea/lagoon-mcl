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
  
  #return_list <- list(path_homogeneity_score = "homogeneity_score_label_Gene3D_I4.tsv",
   #                   inflation = "4",
   #                   label = "label_Gene3D",
   #                   characteristic = "all")
  
  return(return_list)
}


LoadDataframe <- function(path_dataframe) {
  dataframe <- read.table(path_dataframe, sep = "\t", header = TRUE)
  
  return(dataframe)
}


PlotSize <- function(dataframe_input, inflation, label) {
   
   cc_size_all <- dataframe_input %>% 
      select(CC, CC_size_all) %>% 
      ggplot(aes(x = CC_size_all)) +
      geom_histogram(bins = 100, color = "black", fill = "#31688e") +
      theme_light() +
      labs(title =  paste("Distribution cluster size (",gsub("_", " ", label),"all sequences)", "- Inflation: ", inflation),
           subtitle = "Homogeneity score calculated with all sequences present in the cluster",
           x = "Clusters size",
           y = "Number of clusters") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   cc_size_annotated <- dataframe_input %>% 
      select(CC, CC_size_annotated) %>% 
      ggplot(aes(x = CC_size_annotated)) +
      geom_histogram(bins = 100, color = "black", fill = "#35b779") +
      theme_light() +
      labs(title =  paste("Distribution cluster size (",gsub("_", " ", label),"annotated sequences)", "- Inflation: ", inflation),
           subtitle = "Homogeneity score calculated with only annotated sequences present in the cluster",
           x = "Clusters size",
           y = "Number of clusters") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   plot_size = list(cc_size_all = cc_size_all,
                    cc_size_annotated = cc_size_annotated)
   return(plot_size)
}


PlotHomSc <- function(dataframe_input, inflation, label) {
   
   hom_sc_all <- dataframe_input %>% 
      select(CC, homogeneity_score_all) %>% 
      filter(homogeneity_score_all != "unannotated") %>% 
      ggplot(aes(x = as.numeric(homogeneity_score_all))) +
      geom_histogram(bins = 100, color = "black", fill = "#31688e") +
      theme_light() +
      labs(title =  paste("Homogeneity score distribution (",gsub("_", " ", label),"all sequences)", "- Inflation: ", inflation),
           subtitle = "Homogeneity score calculated with all sequences present in the cluster",
           x = "Homogeneity score",
           y = "Number of clusters") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   hom_sc_annotated <- dataframe_input %>% 
      select(CC, homogeneity_score_annotated) %>% 
      filter(homogeneity_score_annotated != "unannotated") %>% 
      ggplot(aes(x = as.numeric(homogeneity_score_annotated))) +
      geom_histogram(bins = 100, color = "black", fill = "#35b779") +
      theme_light() +
      labs(title =  paste("Homogeneity score distribution (",gsub("_", " ", label),"annotated sequences)", "- Inflation: ", inflation),
           subtitle = "Homogeneity score calculated with only annotated sequences present in the cluster",
           x = "Homogeneity score",
           y = "Number of clusters") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   plot_hom_sc = list(hom_sc_all = hom_sc_all,
                      hom_sc_annotated = hom_sc_annotated)
   return(plot_hom_sc)
}


PlotHomScSize <- function(dataframe_input, inflation, label) {
   
   hom_sc_cc_size_all <- dataframe_input %>% 
      select(CC, CC_size_all, CC_size_annotated, homogeneity_score_all) %>% 
      filter(homogeneity_score_all != "unannotated") %>% 
      ggplot(aes(x = CC_size_all, y = CC_size_annotated, color = as.numeric(homogeneity_score_all))) +
      geom_point(alpha = 0.3, shape = 21) +
      theme_light()  +
      labs(title = "Homogeneity score as a function of total number of 
           sequences and number of annotated sequences in clusters",
           subtitle = "Homogeneity score calculated with all sequence present in the cluster",
           x = "all sequence",
           y = "Number of sequence annotated") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   hom_sc_cc_size_annotated <- dataframe_input %>% 
      select(CC, CC_size_all, CC_size_annotated, homogeneity_score_annotated) %>% 
      filter(homogeneity_score_annotated != "unannotated") %>% 
      ggplot(aes(x = CC_size_all, y = CC_size_annotated, color = as.numeric(homogeneity_score_annotated))) +
      geom_point(alpha = 0.3, shape = 21) +
      theme_light()  +
      labs(title = "Homogeneity score as a function of total number of 
           sequences and number of annotated sequences in clusters",
           subtitle = "Homogeneity score calculated with only annotated sequences present in the cluster",
           x = "all sequence",
           y = "Number of sequence annotated") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   plot_hom_sc_size = list(hom_sc_cc_size_all = hom_sc_cc_size_all,
                           hom_sc_cc_size_annotated = hom_sc_cc_size_annotated)
   return(plot_hom_sc_size)
}


PlotHomScSizePourc <- function(dataframe_input, inflation, label) {
   
   hom_sc_cc_size_all_pourc <- dataframe_input %>% 
      select(CC, CC_size_all, CC_size_annotated, homogeneity_score_all) %>% 
      filter(homogeneity_score_all != "unannotated") %>% 
      mutate(pourc = CC_size_annotated / CC_size_all * 100) %>% 
      ggplot(aes(x = CC_size_all, y = pourc, color = as.numeric(homogeneity_score_all))) +
      geom_point(alpha = 0.8, shape = 21) +
      theme_light() +
      labs(title = "?",
           x = "all sequence",
           y = "Number of sequence annotated") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   hom_sc_cc_size_annotated_pourc <- dataframe_input %>% 
      select(CC, CC_size_all, CC_size_annotated, homogeneity_score_annotated) %>% 
      filter(homogeneity_score_annotated != "unannotated") %>% 
      mutate(pourc = CC_size_annotated / CC_size_all * 100) %>% 
      ggplot(aes(x = CC_size_all, y = pourc, color = as.numeric(homogeneity_score_annotated))) +
      geom_point(alpha = 0.8, shape = 21) +
      theme_light() +
      labs(title = "?",
           x = "all sequence",
           y = "Number of sequence annotated") +
      theme(plot.title = element_text(face = "bold", hjust = 0.5))
   
   plot_hom_sc_size_pourc = list(hom_sc_cc_size_all_pourc = hom_sc_cc_size_all_pourc,
                                 hom_sc_cc_size_annotated_pourc = hom_sc_cc_size_annotated_pourc)
   return(plot_hom_sc_size_pourc)
}


MainFunction <- function() {
  args <- LoadData()
  
  df_homogeneity_score <- LoadDataframe(args$path_homogeneity_score)
  
  
  plot_size <- PlotSize(df_homogeneity_score, args$inflation, args$label)
  plot_hom_sc <- PlotHomSc(df_homogeneity_score, args$inflation, args$label)
  plot_hom_sc_size <- PlotHomScSize(df_homogeneity_score, args$inflation, args$label)
  plot_hom_sc_size_pourc <- PlotHomScSizePourc(df_homogeneity_score, args$inflation, args$label)
  
  pdf(file = paste("cluster_analysis", args$label, "_I",
                   args$inflation, "_", ".pdf"), 
      onefile = TRUE)
  
  print(plot_size$cc_size_all)
  print(plot_size$cc_size_annotated)
  print(plot_hom_sc$hom_sc_all)
  print(plot_hom_sc$hom_sc_annotated)
  print(plot_hom_sc_size$hom_sc_cc_size_all)
  print(plot_hom_sc_size$hom_sc_cc_size_annotated)
  print(plot_hom_sc_size_pourc$hom_sc_cc_size_all_pourc)
  print(plot_hom_sc_size_pourc$hom_sc_cc_size_annotated_pourc)
  
  dev.off()
}


if(!interactive()) {
  MainFunction()
}