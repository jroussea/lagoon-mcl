#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 21:36:14 2024

@author: jeremy
"""


import pandas as pd
import sys


def load_dataframe(path_network, path_attributes, list_columns):
    
    network = pd.read_csv(path_network, sep = "\t")
    attributes = pd.read_csv(path_attributes, names = list_columns, sep = "\t")
    
    return(network, attributes)


def homogenity_score(dataframe, column1, column2, column):
    
    dataframe[f"{column}_homogeneity_score"] = dataframe[column1] \
        / dataframe[column2]
    
    return(dataframe)


def condition1(column_name, network_attributes):
    
    column = column_name[0]
        
    cc_attributes = network_attributes[["CC", column]]
    cc_attributes = cc_attributes.dropna()
    cc_attributes = cc_attributes.groupby(["CC", column], as_index = False) \
        .value_counts()

    cc_nodes = network_attributes[["CC", "darkdino_sequence_id"]]
    cc_nodes = cc_nodes.dropna()
    cc_nodes = cc_nodes.drop_duplicates()
    cc_nodes = cc_nodes.groupby("CC", as_index = False).count()

    cc_attributes_nodes = pd.merge(cc_attributes, cc_nodes, how="left", 
                                   on="CC")

    dataframe = homogenity_score(cc_attributes_nodes, "count",
                                 "darkdino_sequence_id", column)

    dataframe = dataframe.drop(["count", "darkdino_sequence_id"], axis = 1)
    
    return(dataframe)


def condition2(column_name, network_attributes):
    
    column_name = ["database", "identifiant"]
    column = ["CC"]
    column.extend(column_name)
        
    cc_attributes = network_attributes[column]
    cc_attributes = cc_attributes.dropna()
    cc_attributes = cc_attributes.groupby(column, as_index = False) \
        .value_counts()


    cc_nodes = network_attributes[["CC", "darkdino_sequence_id"]]
    cc_nodes = cc_nodes.dropna()
    cc_nodes = cc_nodes.drop_duplicates()
    cc_nodes = cc_nodes.groupby("CC", as_index = False).count()

    cc_attributes_nodes = pd.merge(cc_attributes, cc_nodes, how = "left", 
                                   on = "CC")

    dataframe = homogenity_score(cc_attributes_nodes, "count", 
                                 "darkdino_sequence_id", column_name[1])
                
    dataframe = dataframe.drop(["count", "darkdino_sequence_id"], axis = 1)
    
    return(dataframe)


def save_dataframe(dataframe, column_name, basename):
    
    basename = basename.split("_")
    inflation = basename[1]
    
    dataframe.to_csv(f"{inflation}_{column_name[-1]}_homogeneity_score.tsv", 
                     sep = "\t", index = None, na_rep = "NA")


def main(columns_infos, path_network, path_attributes, basename):
    
    columns_infos_split = columns_infos.split(",")
    list_infos = []

    for position in columns_infos_split:
        position = position.split("-")
        list_infos.append(position)

    colname = columns_infos.replace("-", ",")

    list_columns = colname.split(",")

    list_columns.append("darkdino_sequence_id")


    network, attributes = load_dataframe(path_network, path_attributes,
                                         list_columns)


    network_attributes = pd.merge(network, attributes, how="left",
                                  on="darkdino_sequence_id")

    for column_name in list_infos:
        
        if len(column_name) == 1:

            dataframe = condition1(column_name, network_attributes)
            
            save_dataframe(dataframe, column_name, basename)
            
        if len(column_name) == 2:
            
            dataframe = condition2(column_name, network_attributes)
            
            save_dataframe(dataframe, column_name, basename)


if __name__ == '__main__':
    
    columns_infos = sys.argv[1]
    path_network = sys.argv[2]
    path_attributes = sys.argv[3]
    basename = sys.argv[4]

    #columns_infos = "database-identifiant,interproscan"
    #path_network = "network_I14.tsv"
    #path_attributes = "test.tsv"
    #basename = "network_I14"

    main(columns_infos, path_network, path_attributes, basename)



#columns_infos = "database-identifiant,interproscan"
#path_network = "network_I14.tsv"
#path_attributes = "test.tsv"
#basename = "network_I14"

#main(columns_infos, path_network, path_attributes, basename)

#basename = basename.split("_")
