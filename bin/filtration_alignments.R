#!/usr/bin/env Rscript


################################################################################
# PACKAGES
################################################################################


library(dplyr)
library(magrittr)
library(tidyr)
library(scales)
library(ggplot2)


################################################################################
# FUNCTIONS
################################################################################


LoadingData <- function() {
  
  "
  
  Parameters
  ----------
  path_dataframe : STRING
      path to diamond isssu dataframe
  identity : FLOAT
      minimum identity percentage for filtration
  overlap : FLOAT
      minimum overlap percentage for filtration
  evalue : FLOAT
      maximum evalue for filtration
  filtration : BOOLEAN
      TRUE OR FALSE, allows you to specify whether filtration is to be applied
      to data from diamond

  Returns
  -------
  vecteur de toutes les informations

  "
  
  args <- commandArgs(TRUE)
  
  #return_list <- list(path_dataframe = "",
  #                    identity = 60,
  #                    overlap = 80,
  #                    evalue = 1e-50,
  #                    filtration = "true",
  #                    column_query = 1,
  #                    column_subject = 2,
  #                    column_id = 8,
  #                    column_ov = 9,
  #                    column_ev = 10)
  
  
  return_list <- list(path_dataframe = as.character(args[1]),
                      identity = as.numeric(args[2]),
                      overlap = as.numeric(args[3]),
                      evalue = as.numeric(args[4]),
                      filtration = as.character(args[5]),
                      column_query = as.numeric(args[6]),
                      column_subject = as.numeric(args[7]),
                      column_id = as.numeric(args[8]),
                      column_ov = as.numeric(args[9]),
                      column_ev = as.numeric(args[10]))
  
  return(return_list)
}


LoadingDataframe <- function(path_dataframe) {
  
  "
  
  Parameters
  ----------
  path_dataframe : STRING
      path to diamond isssu dataframe

  Returns
  -------
  dataframe

  "
  
  dataframe <- read.table(path_dataframe[1], sep = "\t", header = FALSE)
  
  return(dataframe)
}


SelectColumns <- function(dataframe, columns) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe

  Returns
  -------
  Sequence selection containing sequence identifiers (V1 and V2), identity and
  overlap percentages (V3 and V4) and evalue (V12)
  
  "
  
  
  
  dataframe <- dataframe %>% 
    select(all_of(columns))
  
  return(dataframe)
}


RenameColumns <- function(dataframe, columns) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns()

  Returns
  -------
  dataframe (columns have been renamed)
  
  "
  
  dataframe <- rename(dataframe,
                      query_seq = columns[1],
                      subject_seq = columns[2],
                      identity = columns[3],
                      overlap = columns[4],
                      evalue = columns[5])
  
  return(dataframe)
}


NegLogTransformation <- function(dataframe) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns() 
      an renme with RenameColumns()

  Returns
  -------
  the values in the evalue column have been transformed with the negative 
  logarithm base 10 function
  
  "
  
  dataframe <- dataframe %>% 
    mutate(neglog_evalue = -log(evalue, base = 10))
  return(dataframe)
}


CreationPlots <- function(dataframe, column) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns() 
      and renme with RenameColumns()
      and transfor with NegLogTransformation()
  column: VECTOR
      Vector containing column names
      
  Returns
  -------
  plot of percentage identity distribution, overlap and evalue
  
  "
  
  if (column == "identity") {
    title_labs <- "Identity percentage"
    x_labs <- "Identity (%)"
  }
  if (column == "overlap") {
    title_labs <- "Overlap percentage"
    x_labs <- "Overlap (%)"
  }
  if (column == "neglog_evalue") {
    title_labs <- "Evalue transformed with negative logarithm base 10"
    x_labs <- "Evalue (-log10 transformation)"
  }
  
  graph <- dataframe %>%
    ggplot(aes(x = dataframe[,column])) +
    geom_histogram(bins = 50, color="darkblue", fill="lightblue") +
    scale_y_continuous(labels = label_number()) + 
    theme_light() +
    labs(title = title_labs,
         x = x_labs,
         y = "Count") +
    theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
          axis.title = element_text(size = 14),
          axis.text = element_text(size = 12))
  
  return(graph)
}


MultiPlot <- function(dataframe, file_name) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns() 
      and renme with RenameColumns()
      and transfor with NegLogTransformation()
  file_name: STRING
      name of the pdf that will contain the different plots
      obtained with CreationPlots()
      
  Returns
  -------
  pdf that will contain the different plots obtained with CreationPlots()

  "
  
  target_variables <- c("identity", "overlap", "neglog_evalue")
  
  pdf(file = file_name, onefile = TRUE)
  
  lapply(target_variables,
         function(variable){
           graph <- CreationPlots(dataframe, variable)
           print(graph)
         })
  
  dev.off()
}


FiltrationAlignments <- function(dataframe, val_identity, val_overlap, 
                                 val_evalue) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns() 
      and renme with RenameColumns()
      and transfor with NegLogTransformation()
  val_identity: FLOAT
      minimum identity percentage for filtration
  val_overlap: FLOAT
      minimum overlap percentage for filtration
  val_evalue: FLOAT
      maximum evalue for filtration
      
  Returns
  -------
  filtered dataframe
  deletion of alignments that do not meet the identity, overlap and evalue
  
  "
  
  dataframe <- dataframe %>% 
    filter(identity >= val_identity) %>% 
    filter(overlap >= val_overlap) %>% 
    filter(evalue <= val_evalue)
  
  return(dataframe)
}


SavingDataframe <- function(dataframe, file_name) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns() 
      and renme with RenameColumns()
      and transfor with NegLogTransformation()
  file_name: STRING
      pdf name
      
  Returns
  -------
  pdf containing the studs
  
  "
  
  dataframe <- dataframe %>% 
    select(query_seq, subject_seq, evalue)
  write.table(dataframe, file = file_name,
              sep = "\t", row.names = FALSE)  
}


ReplaceInfValue <- function(dataframe) {
  
  "
  
  Parameters
  ----------
  dataframe : DATAFRAME
      diamond isssu dataframe
      columns have been selected with the SelectColumns() 
      and renme with RenameColumns()
      and transfor with NegLogTransformation()
      
  Returns
  -------
  the evalue plot, there are infinite values for evalues equal to 0 before 
  transformation. 
  so that it can appear on the plot, we take the max value (after trnasformation) 
  and add 100 (so that it remains greater than all other values).  
  
  "
  
  max_value <- max(dataframe$neglog_evalue[is.finite(dataframe$neglog_evalue)])
  new_value <- max_value + 100
  dataframe["neglog_evalue"][sapply(dataframe["neglog_evalue"], 
                                    is.infinite)] <- new_value
  
  return(dataframe)
}


MainFunction <- function() {
  
  args <- LoadingData()
  
  tab_diamond_aln <- LoadingDataframe(args$path_dataframe)
  
  list_columns <- colnames(tab_diamond_aln)
  columns <- list_columns[c(args$column_query, args$column_subject, args$column_id,
                            args$column_ov, args$column_ev)]
  
  tab_diamond_aln <- SelectColumns(tab_diamond_aln, columns)
  
  tab_diamond_aln <- RenameColumns(tab_diamond_aln, columns)
  
  tab_diamond_aln <- NegLogTransformation(tab_diamond_aln)
  
  tab_diamond_aln <- ReplaceInfValue(tab_diamond_aln)
  
  
  if (args$filtration == "false") {
    
    file_name <- paste("distribution_without_filtration.pdf")
    
    MultiPlot(tab_diamond_aln, file_name)
    
    file_name <- paste("diamond_ssn_without_filtration.tsv")
    
    SavingDataframe(tab_diamond_aln, file_name)
  }
  
  if (args$filtration == "true") {
    
    file_name <- paste("distribution_before_filtration.pdf")
    
    MultiPlot(tab_diamond_aln, file_name)
    
    tab_diamond_aln <- FiltrationAlignments(tab_diamond_aln,
                                            args$identity, 
                                            args$overlap,
                                            args$evalue)
    
    file_name <- paste("distribution_after_filtration",
                       as.character(args$identity),
                       as.character(args$overlap),
                       paste(as.character(args$evalue), ".pdf",
                             sep = "",
                             collapse = NULL),
                       sep = "_",
                       collapse = NULL)
    
    MultiPlot(tab_diamond_aln, file_name)
    
    file_name <- paste("diamond_ssn_after_filtration",
                       as.character(args$identity),
                       as.character(args$overlap),
                       paste(as.character(args$evalue), ".tsv",
                             sep = "",
                             collapse = NULL),
                       sep = "_",
                       collapse = NULL)
    
    SavingDataframe(tab_diamond_aln, file_name)
  }
}


################################################################################
# MAIN FUNCTION
################################################################################


if(!interactive()) {
  MainFunction()
}
