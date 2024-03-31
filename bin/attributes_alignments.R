#!/usr/bin/env Rscript


library(dplyr)
library(magrittr)


LoadArgs <- function() {
  
  args <- commandArgs(TRUE)
  
  #return_list <- list(path_query = "column_query.tab",
  #                    path_subject = "column_subject.tab",
  #                    path_alignment = "diamond_alignment_test.tsv",
  #                    columnQueryId = 1,
  #                    columnSubjectId = 2)
  
  return_list <- list(path_query = as.character(args[1]),
                      path_subject = as.character(args[2]),
                      path_alignment = as.character(args[3]),
                      columnQueryId = as.numeric(args[4]),
                      columnSubjectId = as.numeric(args[5]))
  
  return(return_list)
}


LoadDataframe <- function(path_query, path_subject, path_alignment) {
  columnQuery <- read.table(path_query, sep = ";", 
                            col.names = c("diamond_query_name", "query_name", 
                                          "file_name", "query_id"))
  columnQuery <- columnQuery %>% 
    select(-c(file_name, query_name))
  
  columnSubject <- read.table(path_subject, sep = ";", 
                              col.names = c("diamond_subject_name", "subject_name",
                                            "file_name", "subject_id"))
  columnSubject <- columnSubject %>% 
    select(-c(file_name, subject_name))
  
  diamond_alignment <- read.table(path_alignment, sep = "\t")
  
  
  list_all_dataframe <- list(columnQuery = as.data.frame(columnQuery), 
                             columnSubject = as.data.frame(columnSubject), 
                             diamond_alignment = as.data.frame(diamond_alignment))

  return(list_all_dataframe)
}


MergeDataframe <- function(dataframe, column_dataframe, diamond_alignment, 
                           column_alignment) {
  
  diamond_alignment <- merge(dataframe, diamond_alignment, 
                             by.x = column_dataframe, by.y = column_alignment, 
                             all.x = FALSE, all.y = TRUE)
  
  return(diamond_alignment)
}


SaveDataframe <- function(dataframe) {
  write.table(dataframe, file = "alignement_with_id.tsv", row.name = FALSE, 
              col.names = FALSE, sep = "\t")
}


MainFunction <- function() {
  
  args <- LoadArgs()
  
  list_all_dataframe  <- LoadDataframe(args$path_query, args$path_subject,
                                       args$path_alignment)
  
  columns_diamond <- colnames(list_all_dataframe$diamond_alignment)
  columnQueryName <- columns_diamond[args$columnQueryId]
  columnSubjectName <- columns_diamond[args$columnSubjectId]
  
  diamond_alignment <- MergeDataframe(list_all_dataframe$columnSubject, 
                                      "diamond_subject_name", 
                                      list_all_dataframe$diamond_alignment, 
                                      columnSubjectName)
  
  diamond_alignment <- MergeDataframe(list_all_dataframe$columnQuery, 
                                      "diamond_query_name", diamond_alignment, 
                                      columnQueryName)
 
  diamond_alignment <- diamond_alignment %>% 
    select(-c(diamond_query_name, diamond_subject_name))
  
  SaveDataframe(diamond_alignment)
  
}


if(!interactive()) {
  MainFunction()
}