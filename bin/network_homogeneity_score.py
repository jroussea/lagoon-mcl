#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 21:36:14 2024

@author: Jérémy Rousseau
"""


import numpy as np
import pandas as pd
from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    
    parser = ArgumentParser(description="")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Datframe containing the network (2 columns: \
                            cluster ID, sequence ID)", 
                        required = True)
    parser.add_argument("-l", "--label", type = str, 
                        help = "Dataframe containing sequence annotation", 
                        required = True)
    parser.add_argument("-i", "--inflation", type = str,
                        help = "Inflation parameter used for clustering", 
                        required = True)
    parser.add_argument("-b", "--basename", type = str,
                        help = "Name of file containing annotations without .tsv", 
                        required = True)
    
    return parser.parse_args()


def load_dataframe(path_network, path_label):
    """
    Parameters
    ----------
    path_network : STR
        Path to TSV file containing network
    path_label : STR
        Path to the file containing the annotations for each sequence

    Returns
    -------
    2 dataframes

    """
    
    network = pd.read_csv(path_network, sep = "\t")
    label = pd.read_csv(path_label, sep = "\t")
    
    return(network, label)


def modification_of_sets(value, slabels):
    """
    Function to apply to each dict element
    """
    
    return value - slabels


def negative_homogeneity_score(cluster, columns_name, column_peptides):
    """
    Description
    -----------
        If the homogeneity score is negative, it is necessary to select the 
                annotations that best explain the cluster.
        A negative score can be found when the number of (unique) annotations 
                in a cluster is greater than the number of sequences.

    Parameters
    ----------
    cluster : DATAFRAME
        Contains annotations for a cluster (obtained with groupby).
    columns_name : STR
        Name of column containing annotations.
    column_peptides : STR
        Obsolète.
    """
    
    # Step 1: set with all nodes
    set_nodes = set(cluster[column_peptides].unique().tolist())

    # Step 2 building a dictionary dictionary :
    # key = label (annotation)
    # value = set of nodes
    dict_labels = cluster.drop("cluster_id", axis = 1) \
        .groupby([columns_name])[column_peptides] \
            .apply(lambda group: set(group.value_counts().index)) \
                .to_dict()

    # Step 3: Dataframe containing the number of retrievals for each label
    df_labels = cluster.drop(["cluster_id", column_peptides], axis = 1) \
        .assign(size = cluster.groupby(columns_name).transform('size')) \
            .drop_duplicates(keep = 'first')

    # Step 4: algorithm to retrieve the annotations that best explain the cluster
    list_labels = []

    while len(set_nodes) > 0:

        # Retrieve the label (annotation) found in the most sequences
        label_max = df_labels.loc[df_labels["size"].idxmax()][columns_name]        
        list_labels.append(label_max)
        set_labels = dict_labels[label_max]

        # Remove the selected sequence from the set
        set_nodes = set_nodes - set_labels
        
        # Dictionary update
        dict_labels = {key:modification_of_sets(value, set_labels) for key, 
                   value in dict_labels.items()}
                
        # Modification of dataframe containing labels (annotations)
        df_tmp = pd.DataFrame.from_dict(dict_labels, orient='index') \
            .reset_index()
        columns_tmp = list(df_tmp.columns)
        df_labels = pd.melt(df_tmp, id_vars = "index", value_vars = columns_tmp) \
            .dropna().drop(["variable", "value"], axis = 1)
        df_labels = df_labels.assign(size = df_labels.groupby("index") \
                                     .transform("size")) \
            .drop_duplicates(keep = 'first')
        df_labels.rename(columns={'index': columns_name}, inplace = True)

    return(list_labels)


def homogeneity_score(cluster, columns_name, cluster_size, column_peptides, 
                      basename, selection):
    """
    Description
    -----------
        Calculation of a homogeneity score for each cluster with at least one 
        annotated sequence
        Equation:
            If nbannot = 1
                -> homsc = 1
            If nbannot > 1
                -> homsc = 1 - nbannot / nbprot
        With:
            homsc: homogeneity score
            nbannot: number of different annotations in a cluster
            nbprot: number of sequences (proteins) in a cluster

    Parameters
    ----------
    cluster : DATAFRAME
        Contains annotations for a cluster (obtained with groupby).
    columns_name : STR
        Name of column containing annotations.
    cluster_size : DATAFRAME
        Number of sequences per cluster.
    column_peptides : STR
        Obsolète.
    basename : STR
        Name of file containing annotations without .tsv extension.
    selection : STR
        all.
    """
    
    cluster.dropna(inplace = True)
    list_label = cluster[columns_name].unique().tolist()
    cc = cluster["cluster_id"].unique().tolist()[0]

    ########################################################################
    ##################### Homogeneity score equal to 1 #####################
    ########################################################################
    
    # If the number of different annotations 1
    # (only one type of annotation in the cluster))
    if len(list_label) == 1:
        hom_score = 1
    
    ########################################################################
    ################### Homogeneity score greater than 1 ###################
    ########################################################################

    elif len(list_label) > 1:
        # Retrieve cluster size from dataframe cluster_size
        cc_size = list(cluster_size.loc[cluster_size["cluster_id"] == cc] \
                       ["cluster_size"])[0]
        
        hom_score = 1-(len(list_label)/cc_size)

        # If the homogeneity score is negative
        if hom_score < 0:
            # Retrieve the annotations that best explain the cluster
            list_label = negative_homogeneity_score(cluster, columns_name,
                                                     column_peptides)

            hom_score = 1-(len(list_label)/cc_size)

    #########################################################################
    ############## Save the different annotations used to ################### 
    ##############     calculate the homogeneity score    ###################
    #########################################################################
    
    if selection == "all":
        print(list_label)
        for label in list_label:
            with open(f"{basename}.txt", 'a', encoding = "utf8") as f:
                f.write(f"{cc}\t{label}\n")

    return(hom_score)


def dataframe_homogeneity_score(network_label, columns_name, cluster_size, 
                                cluster_size_annotated, column_peptides, 
                                inflation, basename):
    """
    Generate dataframe containing homogeneity score for each cluster

    Parameters
    ----------
    network_label : DATAFRAME
        Dataframe containing clusters and sequences with associated annotations.
    columns_name : STR
        Name of column containing annotations.
    cluster_size : DATAFRAME
        Dataframe containing cluster size (number of sequences).
    cluster_size_annotated : DATAFRAME
        Number of sequences with at least one annotation for each cluster.
    inflation : STR
        Inflation parameter.
    basename : STR
        Name of original file containing sequences and annotations without .tsv.

    Returns
    -------
    Datframe

    """
    
    # Homogeneity score calculated by taking into account all sequences in a cluster
    df_homogeneity_score_all = network_label \
        .groupby("cluster_id", as_index = False) \
                        .apply(lambda cluster: \
                               homogeneity_score(cluster, 
                                                 columns_name,
                                                 cluster_size,
                                                 column_peptides,
                                                 basename,
                                                 "all"))
    
    # Homogeneity score calculated by taking into account only sequences with 
    # at least one annotation
    df_homogeneity_score_annotated = network_label \
        .groupby("cluster_id", as_index = False) \
                        .apply(lambda cluster: \
                               homogeneity_score(cluster, 
                                                 columns_name, 
                                                 cluster_size_annotated,
                                                 column_peptides,
                                                 basename,
                                                 "annotated"))

    # Addition of clusters without homogeneity score (NA)
    df_homogeneity_score_all = df_homogeneity_score_all \
        .merge(cluster_size, on = "cluster_id", how = "right") \
            .replace(np.nan, "NA") \
                .rename(columns = {
                    "cluster_id" : "cluster_id",
                    None : "homogeneity_score_all", 
                    "cluster_size" : "cluster_size"
                    })

    # Addition of clusters without homogeneity score (NA)
    df_homogeneity_score_annotated = df_homogeneity_score_annotated \
        .merge(cluster_size_annotated, on = "cluster_id", how = "right") \
            .replace(np.nan, "NA") \
                .rename(columns = {
                    "cluster_id" : "cluster_id",
                    None : "homogeneity_score_annotated", 
                    "cluster_size" : "sequence_annotated"
                    })
    
    df_homogeneity_score = pd.merge(df_homogeneity_score_all, df_homogeneity_score_annotated, on = "cluster_id")
    df_homogeneity_score["database"] = basename
    df_homogeneity_score["inflation"] = inflation
    
    df_homogeneity_score["sequence_annotated"] = pd.to_numeric(df_homogeneity_score["sequence_annotated"], downcast='integer')
    
    return(df_homogeneity_score)


def main(args):
    """
    DESCRIPTION
    -----------
        Calcul un score d'homogénéité pour chaque cluster
        
    INPUT
    -----
        2 dataframe :
            - 1 dataframe containing the clusters and sequences associated 
                with each cluster
            - 1 dataframe listing the sequences and annotations associated 
                with each sequence
                
    OUTPUT
    ------
        1 dataframe containing homogeneity scores for each cluster
    """
    column_peptides = "protein_accession"
    network, label = load_dataframe(args.network, args.label)
        
    network_label = pd.merge(network, label, on = column_peptides, how = 'left') \
        .dropna()
    
    # Dataframe containing cluster size (number of sequences per cluster)
    cluster_size = network.groupby('cluster_id', as_index = False).count() \
        .rename(columns={column_peptides: 'cluster_size'})
    
    columns_name = "database_accession"
    
    network_annotated = network_label.drop([columns_name], axis = 1) \
        .drop_duplicates()
    
    # Cluster size calculated by taking into account only the number of 
    # sequences with at least one annotation
    cluster_size_annotated = network_annotated.groupby('cluster_id', 
                                                       as_index=False) \
        .count().rename(columns={column_peptides: 'cluster_size'})
    cluster_size_annotated = pd.merge(cluster_size \
                                      .drop("cluster_size", axis = 1),
                                      cluster_size_annotated, 
                                      on = "cluster_id", how = "left") \
        .replace(np.nan, 0)
    
    
    ####################################################################
    ######################## Homogeneity scores ########################
    ####################################################################
    
    df_homogeneity_score = dataframe_homogeneity_score(network_label, 
                                                       columns_name, 
                                                       cluster_size, 
                                                       cluster_size_annotated, 
                                                       column_peptides, 
                                                       args.inflation, 
                                                       args.basename)

    #####################################################################
    ############### Save homogeneity scores in a TSV file ###############
    #####################################################################
    
    df_homogeneity_score.to_csv(f"homogeneity_score_{args.basename}_I{args.inflation}.tsv", 
                     sep = "\t", index = None, header = True)


if __name__ == '__main__':
    args = get_args()
    main(args)