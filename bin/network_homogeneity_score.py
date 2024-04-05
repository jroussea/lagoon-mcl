#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 21:36:14 2024

@author: jeremy
"""

import numpy as np
import pandas as pd
import sys


def load_dataframe(path_network, path_attributes, list_columns):
    
    network = pd.read_csv(path_network, sep = "\t")
    attributes = pd.read_csv(path_attributes, names = list_columns, sep = "\t")
    
    return(network, attributes)


def homogeneity_score(df, column, cluster_size):
    
    df.replace('-', np.nan, inplace = True)
    
    list_value = df[column].unique().tolist()
    
    if len(list_value) == 1 and str(list_value[0]) == "nan":
        hom_score = 0
        
    elif len(list_value) == 1 and str(list_value[0]) != "nan":
        hom_score = 1
    
    elif len(list_value) > 1:
        df_drop_na = df.dropna()
        cc = df["CC"].unique().tolist()
        num_annot = df_drop_na[column].value_counts().count()
        #num_sequence = df["darkdino_sequence_id"].value_counts().count()
        cc_size = cluster_size.loc[cluster_size["CC"] == cc[0]]
        
        num_sequence = list(cc_size["number_of_sequence"])[0]
        
        hom_score = 1-(num_annot/num_sequence)

    return(hom_score)


def save_dataframe(dataframe, inflation, filtration):
    
    dataframe.to_csv(f"homogeneity_score_{inflation}_{filtration}.tsv", 
                     sep = "\t", index = None)


def main(columns_infos, path_network, path_attributes, inflation, filtration):
    
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
           
    
    cluster_size = network.groupby('CC', as_index=False).count()
    cluster_size = cluster_size \
        .rename(columns={"darkdino_sequence_id": "number_of_sequence"})
    result = cluster_size
    
    
    
    for column_name in list_infos:
            
        if len(column_name) == 1:
            
            column = column_name[0]
            
            cc_attributes = network_attributes[["CC", "darkdino_sequence_id", 
                                                column]]
            
            df_homogeneity_score = cc_attributes.groupby("CC", 
                                                         as_index = False) \
                .apply(lambda df: homogeneity_score(df, column, cluster_size))
            
            df_homogeneity_score = df_homogeneity_score \
                .rename(columns={None: f"{column}_homogeneity_score"})
            
            result = pd.merge(result, df_homogeneity_score, how = "left", 
                              on = "CC")
            
        elif len(column_name) > 1:
            
            columnA = column_name[0]
            columnB = column_name[1]
            # récupération des colonnes intéressante
            cc_attributes = network_attributes[["CC", "darkdino_sequence_id",
                                                columnA, columnB]]
            # dataframe du score d'homogénéité (3 colonnes)
            df_homogeneity_score = cc_attributes \
                .groupby(["CC", columnA], as_index = False) \
                    .apply(lambda df: homogeneity_score(df, columnB, 
                                                        cluster_size))
            # renomer la ccolonne none 
            df_homogeneity_score = df_homogeneity_score \
                .rename(columns={None: "homogeneity_score"})
            # long to wide, permet d'avoirt 1 ligne = 1 cc 
            df_homogeneity_score = df_homogeneity_score \
                .pivot(index = "CC", columns="analysis", 
                       values="homogeneity_score")
            # ajout de prefix au nom des colonnes
            df_homogeneity_score.columns += "_homogeneity_score"
            # renommer la colonne car la précédente ne fait pas la diff
            df_homogeneity_score = df_homogeneity_score. \
                rename(columns={"CC_homogeneity_score": "CC"})
            # inde to column
            df_homogeneity_score = df_homogeneity_score.reset_index()
            # ajout du dataframe intermédiaire dans le tafgrame résult
            result = pd.merge(result, df_homogeneity_score, how = "left", 
                              on = "CC")
    
    # convertir nan en 0
    result.replace(np.nan, 0, inplace = True)
    
    # sauvegarde du dataframe
    save_dataframe(result, inflation, filtration)


if __name__ == '__main__':
    
    columns_infos = sys.argv[1]
    path_network = sys.argv[2]
    path_attributes = sys.argv[3]
    inflation = sys.argv[4]
    filtration = sys.argv[5]

    #columns_infos = "database-identifiant,interproscan"
    #path_network = "network_I14.tsv"
    #path_attributes = "test.tsv"
    #basename = "network_I14"

    main(columns_infos, path_network, path_attributes, inflation, filtration)
