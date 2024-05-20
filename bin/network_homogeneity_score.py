#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 21:36:14 2024

@author: jeremy
"""

import numpy as np
import pandas as pd
import sys


def load_dataframe(path_network, path_label):
    
    network = pd.read_csv(path_network, sep = "\t")
    label = pd.read_csv(path_label, sep = "\t")
    
    return(network, label)


def select_singleton(cluster_size):
    
    singleton = cluster_size.loc[cluster_size["CC_size"] == 1]
    
    cluster_size.drop(cluster_size[cluster_size.CC_size == 1].index,
                      inplace=True)
    
    return(singleton, cluster_size)


def modification_of_sets(value, slabels):
    ''' Function to apply to each dict element.'''
    return value - slabels


def negative_homogeneity_score(cluster, columns_name, column_peptides):
    
    # étape 1 : un set de tous les noeuds
    set_nodes = set(cluster[column_peptides].unique().tolist())

    # ÉÉtape 2 construire un dictionnaire dictionnaire : clé = label value = 
    #set des noeuds
    # supprimer la colonne CC qui est inutile
    dict_labels = cluster.drop("CC", axis = 1) \
        .groupby([columns_name])[column_peptides] \
            .apply(lambda group: set(group.value_counts().index)) \
                .to_dict()

    # Étape 3 dataframes du nombre de Noeuds par label
    # à mettre à jour à chaque itération
    df_labels = cluster.drop(["CC", "peptides"], axis = 1) \
        .assign(size = cluster.groupby(columns_name).transform('size')) \
            .drop_duplicates(keep = 'first')

    # étape 4 l'algorithme
    list_labels = []

    while len(set_nodes) > 0:

        label_max = df_labels.loc[df_labels["size"].idxmax()][columns_name]
        
        list_labels.append(label_max)
        
        set_labels = dict_labels[label_max]

        set_nodes = set_nodes - set_labels
        
        dict_labels = {key:modification_of_sets(value, set_labels) for key, 
                   value in dict_labels.items()}
                
        # modification du dataframe qui compte les labels
        df_tmp = pd.DataFrame.from_dict(dict_labels, orient='index') \
            .reset_index()
        columns_tmp = list(df_tmp.columns)
        df_labels = pd.melt(df_tmp, id_vars = "index", value_vars = columns_tmp) \
            .dropna().drop(["variable", "value"], axis = 1)
        df_labels = df_labels.assign(size = df_labels.groupby("index") \
                                     .transform("size")) \
            .drop_duplicates(keep = 'first')
        
    return(list_labels)


def homogeneity_score(cluster, columns_name, cluster_size, column_peptides, 
                      basename, selection):
        
    cluster.dropna(inplace = True)
    
    list_label = cluster[columns_name].unique().tolist()
    cc = cluster["CC"].unique().tolist()[0]
    
    if len(list_label) == 1:
        
        hom_score = 1
            
    elif len(list_label) > 1:
        
        sequence_label = len(cluster[column_peptides].unique().tolist())
        
        cc_size = list(cluster_size.loc[cluster_size["CC"] == cc]["CC_size"])[0]

        hom_score = 1-(sequence_label/cc_size)
        
        
        
    #return(hom_score)
        if hom_score < 0:
                        
            list_label = negative_homogeneity_score(cluster, columns_name,
                                                     column_peptides)
            
            hom_score = 1-(len(list_label)/cc_size)
               
    print(list_label)

    for label in list_label:

        with open(f"{basename}_{selection}.txt", 'a', encoding = "utf8") as f:
        
            f.write(f"{cc}\t{label}\n")

    return(hom_score)


def save_dataframe(dataframe, dataframe_type, inflation, basename):
    
    dataframe.rename(columns={None: "homogeneity_score"}, inplace= True)
    
    dataframe.to_csv(f"homogeneity_score_{basename}_I{inflation}_{dataframe_type}.tsv", 
                     sep = "\t", index = None)


def main(path_network, path_label, column_peptides, inflation, basename):
    
    network, label = load_dataframe(path_network, path_label)
    
    label = label.replace('-', np.nan).dropna()
    
    network_label = pd.merge(network, label, on = column_peptides,
                             how = 'left').replace('-', np.nan,).dropna()
    
    cluster_size = network.groupby('CC', as_index=False).count() \
        .rename(columns={column_peptides: 'CC_size'})
    
    #singleton, cluster_size = select_singleton(cluster_size)
    
    columns_name = list(network_label.columns)
    for col in ["CC", column_peptides]:
        columns_name.remove(col)
    columns_name = str(columns_name[0])
    
    network_annotated = network_label.drop([columns_name], axis = 1) \
        .drop_duplicates()
    
    cluster_size_annotated = network_annotated.groupby('CC', as_index=False) \
        .count().rename(columns={column_peptides: 'CC_size'})
    cluster_size_annotated = pd.merge(cluster_size \
                                      .drop("CC_size", axis = 1),
                                      cluster_size_annotated, 
                                      on = "CC", how = "left") \
        .replace(np.nan, 0)
    
    
    df_homogeneity_score = network_label.groupby("CC", as_index = False) \
                        .apply(lambda cluster: \
                               homogeneity_score(cluster, 
                                                 columns_name,
                                                 cluster_size,
                                                 column_peptides, basename,
                                                 "all"))
    
    df_homogeneity_score_annotated = network_label.groupby("CC", 
                                                           as_index = False) \
                        .apply(lambda cluster: \
                               homogeneity_score(cluster, 
                                                 columns_name, 
                                                 cluster_size_annotated,
                                                 column_peptides,
                                                 basename,
                                                 "annotated"))
    
    
    df_homogeneity_score = df_homogeneity_score \
        .merge(cluster_size, on = "CC", how = "right") \
            .replace(np.nan, "unannotated")
    
    df_homogeneity_score_annotated = df_homogeneity_score_annotated \
        .merge(cluster_size_annotated, on = "CC", how = "right") \
            .replace(np.nan, "unannotated")
    
    save_dataframe(df_homogeneity_score, "all", inflation, basename)
    save_dataframe(df_homogeneity_score_annotated, "annotated", inflation, 
                   basename)


if __name__ == '__main__':
    
    path_network = sys.argv[1]
    path_label = sys.argv[2]
    column_peptides = sys.argv[3]
    inflation = sys.argv[4]
    basename = sys.argv[5]

    #path_network = "network_I2.tsv"
    #path_label = "label_interproscan.tsv"
    #column_peptides = "peptides"
    #inflation = 2
    #basename = "label_interproscan"

    main(path_network, path_label, column_peptides, inflation, basename)

