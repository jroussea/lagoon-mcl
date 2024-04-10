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


def modification_of_sets(value, slabels):
    ''' Function to apply to each dict element.'''
    return value - slabels


def negative_homogeneity_score(dataframe, column):
    
    # étape 1 : un set de tous les noeuds
    sNoeuds = set(dataframe["darkdino_sequence_id"].unique().tolist())

    # ÉÉtape 2 construire un dictionnaire 
    # supprimer la colonne CC qui est inutile
    dfLabels = dataframe.drop("CC", axis = 1)
    dLabels = dfLabels.groupby([column])["darkdino_sequence_id"] \
        .apply(lambda grp: set(grp.value_counts().index)).to_dict()

    # Étape 3 dataframes du nombre de Noeuds par label
    # à mettre à jour à chaque itération

    dfLabels = dfLabels.drop("darkdino_sequence_id", axis = 1)
    dfLabels[f"{column}_count"] = dfLabels.groupby(column).transform('size')
    dfLabels = dfLabels.drop_duplicates(keep = 'first')
    # étape 4 l'algorithme

    lLabel = []

    #print(dLabels)

    while len(sNoeuds) > 0:
        SeriesLabels = dfLabels.loc[dfLabels[f"{column}_count"].idxmax()]
        label = SeriesLabels[column]
        
        #print(label)
        
        lLabel.append(label)
        
        sLabels = dLabels[label]
        #print(sNoeuds)
        sNoeuds = sNoeuds - sLabels
        
        dLabels = {key:modification_of_sets(value, sLabels) for key, 
                   value in dLabels.items()}
        
        #print(dLabels)
        
        # modification du dataframe qui compte les labels
        tmp = pd.DataFrame.from_dict(dLabels, orient='index')
        tmp_columns = list(tmp.columns)
        tmp.reset_index(inplace=True, names = column)
        tmp = pd.melt(tmp, id_vars = column, value_vars = tmp_columns).dropna()
        
        dfLabels = tmp.drop(["variable", "value"], axis = 1)
        dfLabels[f"{column}_count"] = dfLabels.groupby(column).transform('size')
        dfLabels = dfLabels.drop_duplicates(keep = 'first')
        
        return(lLabel)


def homogeneity_score(df, column, cluster_size):
    
    df.replace('-', np.nan, inplace = True)
    
    list_value = df[column].unique().tolist()
    
    if len(list_value) == 1 and list_value[0] == np.nan:
        hom_score = 0
        
    elif len(list_value) == 1 and list_value[0] != np.nan:
        hom_score = 1
    
    elif len(list_value) > 1:
        df_drop_na = df.dropna()
        cc = df["CC"].unique().tolist()
        num_annot = df_drop_na[column].value_counts().count()
        cc_size = cluster_size.loc[cluster_size["CC"] == cc[0]]
        
        num_sequence = list(cc_size["number_of_sequence"])[0]
        
        hom_score = 1-(num_annot/num_sequence)
        
        #print(df_drop_na)
        
        if hom_score < 0:
            
            lLabel = negative_homogeneity_score(df_drop_na, column)
            
            hom_score = 1-(len(lLabel)/num_sequence)
            #print(cc)
            #print(hom_score)
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
        print(column_name)
        if len(column_name) == 1:
            print("condition 1")
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
            print("condition2")
            columnA = column_name[0]
            columnB = column_name[1]
            
            cc_attributes = network_attributes[["CC", "darkdino_sequence_id", 
                                                columnA, columnB]]
    
            df_homogeneity_score = cc_attributes.groupby(["CC", columnA], 
                                                         as_index = False) \
                .apply(lambda df: homogeneity_score(df, columnB, cluster_size))
            
            df_homogeneity_score = df_homogeneity_score \
                .rename(columns={None: "homogeneity_score"})
            
            df_homogeneity_score = df_homogeneity_score \
                .pivot(index = "CC", columns=columnA, 
                       values="homogeneity_score")
    
            df_homogeneity_score.columns += "_homogeneity_score"
    
            df_homogeneity_score = df_homogeneity_score \
                .rename(columns={"CC_homogeneity_score": "CC"})
    
            df_homogeneity_score = df_homogeneity_score.reset_index()
    
            result = pd.merge(result, df_homogeneity_score, how = "left", 
                              on = "CC")
    
    
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