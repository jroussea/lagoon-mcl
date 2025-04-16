#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Mar 20 11:07:18 2025

@author: jrousseau
@date: 2025-03-03
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script generates an HTML report
"""


from argparse import ArgumentParser
from jinja2 import Environment, FileSystemLoader
from collections import Counter
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np


def main(args):
    """

    Parameters
    ----------
    args.nodes : TSV
        Nodes / sequences file
    args.clusters : TSV
        Clusters file
    args.edges : TSV
        Edges / alignments file
    args.basename : STR
        Network file name
    args.template : HTML
        HTML template for jinja2
        
    """
    ### Sequence metrics ###
    d_sequences, d_sequence_label, d_metrics = read_nodes_metrics(args.nodes)
    d_clusters_metrics, d_homogeneity, d_clst_caracteristics = read_clusters_metrics(args.clusters, d_metrics)
    d_clusters_metrics = read_edges_files(args.edges, d_clusters_metrics)
    d_counter_label = count_label_per_sequence(d_sequence_label)
    ### (étape 4) Sequence metrics data ###
    data_sequence_metrics = reports_sequences_metrics(d_sequences, args.basename)
    ### (étape 3) Sequence label data ###
    data_sequence_label = reports_sequences_label(d_counter_label, args.basename)
    ### (étape 1) clusters metrics data  ###
    data_clusters_metrics = reports_clusters_metrics(d_clusters_metrics, args.basename)
    ### (étape 2) homogeneity score ###
    data_clusters_labels = reports_clusters_labels(d_homogeneity, d_clst_caracteristics, args.basename)

    num_cluster = len(d_metrics)

    title = str(' '.join(args.basename.split('_')))

    inflation = '.'.join(list(title.split(' ')[1])[1:])

    data = {
            "title": title,
            "inflation": inflation,
            "reports_seq_metrics": data_sequence_metrics,
            "reports_seq_labels": data_sequence_label,
            "reports_clst_metrics": data_clusters_metrics,
            "reports_clst_labels": data_clusters_labels,
            "number_clusters": num_cluster
            }


    env = Environment(loader=FileSystemLoader(args.template))
    template = env.get_template('template.html')
    html_content = template.render(data)


    with open(f'{args.basename}_report.html', 'w') as f:
        f.write(html_content)


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(description="This script generates an HTML report")
    
    parser.add_argument("-n", "--nodes", type = str,
                        help = "Nodes / sequences file", 
                        required = True)
    
    parser.add_argument("-c", "--clusters", type = str,
                        help = "Clusters file", 
                        required = True)    

    parser.add_argument("-e", "--edges", type = str,
                        help = "Edges / alignments file", 
                        required = True)        

    parser.add_argument("-t", "--template", type = str,
                        help = "HTML template for jinja2", 
                        required = True)  
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network file name", 
                        required = True)  
    
    return parser.parse_args()


def read_edges_files(edges, d_clusters_metrics):
    """
    Reading the network-specific alignment file

    Parameters
    ----------
    edges : TSV
        Edges / alignments file
    d_clusters_metrics: DICT
        Key: Cluster ID
        Value: cluster-specific metrics
        
    Returns
    -------
    d_clusters_metrics : DICT
        key: cluster ID
        Value: cluster-specific metrics + number of edges / alignments

    """
    d_edges = dict()

    with open(edges, "r") as f_edges:
        for row in f_edges:
            l_row = row.strip().split("\t")
            if l_row[14] not in d_edges.keys():
                d_edges[l_row[14]] = 1
            else:
                d_edges[l_row[14]] += 1

    l_edges = list()

    for cluster_id in range(0, len(d_edges), 1):
        l_edges.append(d_edges[str(cluster_id)])   

    d_clusters_metrics["edges"] = l_edges

    return d_clusters_metrics


def read_nodes_metrics(nodes):
    """
    Read file containing node/sequence-specific metrics

    Parameters
    ----------
    nodes : TSV
        nodes / sequences file
        
    Returns
    -------
    d_sequences : DICT
        length: list of the length of all sequences
        centrality: list of the centrality of all sequences
    d_sequence_label : DICT
        Key: label or annotation identifier
        Value: list of sequences with this label
    d_metrics : DICT
        Key: Cluster ID
        Value: DIC
            length: list of the length of sequences in the cluster
            centrality: list of the centrality of sequences in the cluster

    """
    d_sequences = {
        "length": [],
        "centrality": []
        }

    d_sequence_label = dict()
    d_position = dict()
    d_metrics = dict()

    with open(nodes, "r") as f_sequence:
        for position, row in enumerate(f_sequence):
            l_row = row.strip().split("\t")
            l_labels = l_row[4:]
            if position == 0:
                for pos, label in enumerate(l_labels):
                    d_position[pos] = label
                    d_sequence_label[label] = list()
            elif position != 0:
                if l_row[1] not in d_metrics.keys():
                    d_metrics[l_row[1]] = {
                        'length': [int(l_row[2])],
                        'centrality': [float(l_row[3])]
                        }
                else:
                    d_metrics[l_row[1]]['length'].append(int(l_row[2]))
                    d_metrics[l_row[1]]['centrality'].append(float(l_row[3]))
                d_sequences["length"].append(int(l_row[2]))
                d_sequences["centrality"].append(float(l_row[3]))
                for pos, label in enumerate(l_labels):
                    d_sequence_label[d_position[(pos)]].append(label)
    
    return d_sequences, d_sequence_label, d_metrics


def read_clusters_metrics(clusters, d_metrics):
    """
    Read file containing cluster-specific metrics

    Parameters
    ----------
    clusters : TSV
        Clusters file
    d_metrics : DICT
        Key: Cluster ID
        Value: DIC
            length: list of the length of sequences in the cluster
            centrality: list of the centrality of sequences in the cluster
        
    Returns
    -------
    d_clusters_metrics : DICT
        sequence_id: list of clusters
        cluster_size: list of cluster sizes
        diameter: list of cluster diameters
        mean_centrality: list of average centrality for each cluster
        mean_length: list of average sequence length for each cluster
        max_centrality: maximum centrality for each cluster
        max_length: maximum sequence length for each cluster
    d_homogeneity : DICT
        Key: annotation type name
        Value: DICT
            cluster_id: list of cluster identifiers
            homogeneity_score: list of homogeneity scores
            seq_annot: list of annotated sequences
            number_of_label: list of number of annotations per cluster
            prop_annot: list of proportion of sequences annotated by clusters
            cluster_size: list of cluster sizes
            seq_unannot: list of number of unannotated sequences per cluster
            prop_unannot: list of proportion of unannotated sequences per cluster
    d_clst_caracteristics : DICT
        Key: annotation type name
        Value: DICT
            clst_annot: list of clusters with at least one annotated sequence
            clst_unannot: list of clusters with no annotated sequence

    """
    d_clusters_metrics = {'sequence_id': [], 'cluster_size': [], 'diameter': [],
        'mean_centrality': [], 'mean_length': [], 'max_centrality': [], 'max_length': []}

    d_position = dict()
    d_homogeneity = dict()
    d_clst_caracteristics = dict()
    
    with open(clusters, "r") as f_cluster:
        for position, row in enumerate(f_cluster):
            l_row = row.strip().split("\t")
            l_hom_sc = l_row[3:]
            ll_hom_sc = [l_hom_sc[i:i+3] for i in range(0, len(l_hom_sc), 3)]
            if position == 0:
                for pos, l_label in enumerate(ll_hom_sc):
                    label = '_'.join(l_label[0].split("_")[:-2])
                    d_position[pos] = label
                    d_homogeneity[label] = {
                        "cluster_id": [],
                        "homogeneity_score": [],
                        "seq_annot": [],
                        "number_of_label": [],
                        "prop_annot": [],
                        "cluster_size": [],
                        "seq_unannot": [],
                        "prop_unannot":[]
                        }
                    d_clst_caracteristics[label] ={
                        "clst_annot": [],
                        "clst_unannot": []
                        }
            elif position != 0:
                d_clusters_metrics["sequence_id"].append(l_row[0])
                d_clusters_metrics["cluster_size"].append(int(l_row[1]))
                d_clusters_metrics["diameter"].append(float(l_row[2]))
                d_clusters_metrics["mean_centrality"].append(float(np.round(np.mean(d_metrics[l_row[0]]["centrality"]), 3)))
                d_clusters_metrics["mean_length"].append(float(np.round(np.mean(d_metrics[l_row[0]]["length"]), 3)))
                d_clusters_metrics["max_centrality"].append(float(np.round(np.max(d_metrics[l_row[0]]["centrality"]), 3)))
                d_clusters_metrics["max_length"].append(int(np.round(np.max(d_metrics[l_row[0]]["length"]), 3)))
                
                for pos, l_label in enumerate(ll_hom_sc):
                    label = d_position[pos]
                    if l_label[0] != "NA":
                        unannotated_sequence = int(l_row[1])-int(l_label[1])
                        
                        d_homogeneity[label]["cluster_id"].append(l_row[0])
                        d_homogeneity[label]["homogeneity_score"].append(float(l_label[0]))
                        d_homogeneity[label]["seq_annot"].append(int(l_label[1]))
                        d_homogeneity[label]["number_of_label"].append(int(l_label[2]))
                        d_homogeneity[label]["prop_annot"].append(float(round(int(l_label[1])/int(l_row[1])*100, 3)))
                        d_homogeneity[label]["cluster_size"].append(int(l_row[1]))
                        d_homogeneity[label]["seq_unannot"].append(unannotated_sequence)
                        d_homogeneity[label]["prop_unannot"].append(float(round(int(unannotated_sequence/int(l_row[1]))*100, 3)))
    
                        d_clst_caracteristics[label]["clst_annot"].append(int(l_row[1]))
                        
                    elif l_label[0] == "NA":
                        d_clst_caracteristics[label]["clst_unannot"].append(int(l_row[1]))
    
    return d_clusters_metrics, d_homogeneity, d_clst_caracteristics


def count_label_per_sequence(d_sequence_label):
    """
    Counting the number of annotations per sequence

    Parameters
    ----------
    d_sequence_label : DICT
        Key: label or annotation identifier
        Value: list of sequences with this label
        
    Returns
    -------
    d_counter_label : DICT
        Key: annotation type name
        Value: DICT
            0 label: number of sequences with 0 annotations
            1 label : number of sequences with 1 annotation
            2 or more labels: number of sequences with at least 2 annotations

    """
    d_counter_label = dict()
    for label, l_occurance in d_sequence_label.items():
        d_counter = dict(Counter(l_occurance))
        d_counter_label[label] = dict()
        for key, value in sorted(d_counter.items()):
            if  int(key) == 0:
                d_counter_label[label]["0 label"] = int(value)
            elif int(key) == 1:
                d_counter_label[label]["1 label"] = int(value)
            elif int(key) >= 2:
                d_counter_label[label]["2 or more labels"] = int(value)
    
    return d_counter_label
    

def reports_sequences_metrics(d_sequences, basename):
    """
    Report on sequence metrics

    Parameters
    ----------
    d_sequence_label : DICT
        Key: label or annotation identifier
        Value: list of sequences with this label
    basename : STR
        Network file name
        
    Returns
    -------
    data_sequence_metrics : DICT
        plot: figure in png format
        dataframe: dataframe in HTML format

    """
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(15, 5))
    sns.set_theme(style="ticks")
    sns.despine(fig)

    sns.histplot(
        x=d_sequences["length"],
        kde = True,
        ax=axes[0]
    )
    axes[0].set_title("Figure 10")
    axes[0].set_xlabel("Sequence length")
    axes[0].set_ylabel("Frequency")

    sns.histplot(
        x=d_sequences["centrality"],
        kde = False,
        ax=axes[1]
    )
    axes[1].set_title("Figure 11")
    axes[1].set_xlabel("Sequence centrality")
    axes[1].set_ylabel("Frequency")

    sns.scatterplot(
        x=d_sequences["length"],
        y=d_sequences["centrality"],
        ax=axes[2]
    )
    axes[2].set_title("Figure 12")
    axes[2].set_xlabel("Sequence length")
    axes[2].set_ylabel("Sequence centrality")

    plt.tight_layout()

    plt.savefig(f"{basename}_figures/sequence_length_centrality.png", format="png")

    data_sequence_metrics = {
        "Statistics": ["Mean", "Meadian", "Max", "Min"],
        "Sequence length": [
            str(np.round(np.mean(d_sequences["length"]), 3)),
            str(np.round(np.median(d_sequences["length"]), 3)),
            str(np.max(d_sequences["length"]).astype(int)),
            str(np.min(d_sequences["length"]).astype(int))
            ],
        "Sequence centrality": [
            str(np.round(np.mean(d_sequences["centrality"]), 3)),
            str(np.round(np.median(d_sequences["centrality"]), 3)),
            str(np.max(d_sequences["centrality"]).astype(int)),
            str(np.min(d_sequences["centrality"]).astype(int))
            ]
        }

    df_sequence_metrics = pd.DataFrame(data_sequence_metrics)
    df_sequence_metrics_html = df_sequence_metrics.to_html(index=False)

    data_sequence_metrics = {
        'plot': f"{basename}_figures/sequence_length_centrality.png",
        'dataframe': df_sequence_metrics_html
        }

    return data_sequence_metrics


def reports_sequences_label(d_counter_label, basename):
    """
    Report on sequence labels

    Parameters
    ----------
    d_counter_label : DICT
        Key: annotation type name
        Value: DICT
            0 label: number of sequences with 0 annotations
            1 label : number of sequences with 1 annotation
            2 or more labels: number of sequences with at least 2 annotations
    basename : STR
        Network file name
        
    Returns
    -------
    data_clusters_sequences : DICT
        plot: figure in png format
        dataframe: dataframe in HTML format

    """
    data_sequence_label = dict()
    
    for label, d_counter in d_counter_label.items():
        
        data_counter = {'Category': [], 'Value': [], 'Percentage': []}
        
        sum_sequences = sum(d_counter.values())
        
        for key, value in d_counter.items():
            data_counter['Category'].append(str(key))
            data_counter['Value'].append(int(value))
            data_counter['Percentage'].append(round(float((value/sum_sequences)*100), 3))
            

        fig, axes = plt.subplots(nrows=1, ncols=1, figsize=(5, 5))
        sns.set_theme(style="ticks")
        sns.despine(fig)
        
        ax = sns.barplot(
            x=data_counter['Category'],
            y=data_counter['Percentage'],
            palette='Blues_d'
        )
        ax.set_title("Figure 9", fontsize=16)
        for p in ax.patches:
            ax.annotate(
                f'{p.get_height()}%',                             # Text to be displayed (the value of each bar)
                (p.get_x() + p.get_width() / 2., p.get_height()), # Text position (at the top of each bar)
                ha='center',                                      # Horizontal alignment (center of bar)
                va='center',                                      # Vertical alignment (at top of bar)
                fontsize=12,                                      # Font size
                color='black',                                    # Text color
                xytext=(0, 5),                                    # Shift the text to a slightly higher position
                textcoords='offset points'                        # Using the stitch unit for offset
            )
            
        plt.tight_layout()

        plt.savefig(f"{basename}_figures/sequence_label_{label}.png", format="png")
        
        df_counter = pd.DataFrame(data_counter)
        df_counter_html = df_counter.to_html(index=False)

        name = ' '.join(label.split('_')[1:-1])
        data_sequence_label[name] = {
            'plot': f"{basename}_figures/sequence_label_{label}.png",
            'dataframe': df_counter_html
            }

    return data_sequence_label


def reports_clusters_metrics(d_clusters_metrics, basename):
    """
    Report on clusters metrics

    Parameters
    ----------
    d_clusters_metrics : DICT
        sequence_id: list of clusters
        cluster_size: list of cluster sizes
        diameter: list of cluster diameters
        mean_centrality: list of average centrality for each cluster
        mean_length: list of average sequence length for each cluster
        max_centrality: maximum centrality for each cluster
        max_length: maximum sequence length for each cluster
    basename : STR
        Network file name
        
    Returns
    -------
    data_clusters_sequences : DICT
        plot: figure in png format
        dataframe: dataframe in HTML format

    """
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(15, 5))
    sns.set_theme(style="ticks")
    sns.despine(fig)
    
    sns.histplot(
        x=d_clusters_metrics["cluster_size"],
        kde = True,
        ax=axes[0]
    )
    axes[0].set_title("Figure 1")
    axes[0].set_xlabel("Cluster sizz")
    axes[0].set_ylabel("Frequency")
    
    sns.histplot(
        x=d_clusters_metrics["diameter"],
        kde = True,
        ax=axes[1]
    )
    axes[1].set_title("Figure 2")
    axes[1].set_xlabel("Diameter")
    axes[1].set_ylabel("Frequency")
    
    sns.scatterplot(
        x=d_clusters_metrics["cluster_size"],
        y=d_clusters_metrics["edges"],
        ax=axes[2]
    )
    axes[2].set_title("Figure 3")
    axes[2].set_xlabel("Cluster size")
    axes[2].set_ylabel("Number of edges / clusters")
    
    plt.tight_layout()

    plt.savefig(f"{basename}_figures/clusters_metrics.png", format="png")

    d_results = {
        "Statistics": ["Mean", "Median", "Max", "Min"],
        "Cluster size": [
            str(np.round(np.mean(d_clusters_metrics["cluster_size"]), 3)),
            str(np.round(np.median(d_clusters_metrics["cluster_size"]), 3)),
            str(np.max(d_clusters_metrics["cluster_size"]).astype(int)),
            str(np.min(d_clusters_metrics["cluster_size"]).astype(int))
            ],
        "Cluster diameter": [
            str(np.round(np.mean(d_clusters_metrics["diameter"]), 3)),
            str(np.round(np.median(d_clusters_metrics["diameter"]), 3)),
            str(np.max(d_clusters_metrics["diameter"]).astype(int)),
            str(np.min(d_clusters_metrics["diameter"]).astype(int))
            ],
        "Cluster eges": [
            str(np.round(np.mean(d_clusters_metrics["edges"]), 3)),
            str(np.round(np.median(d_clusters_metrics["edges"]), 3)),
            str(np.max(d_clusters_metrics["edges"]).astype(int)),
            str(np.min(d_clusters_metrics["edges"]).astype(int))
            ],
        }

    df_clusters_metrics = pd.DataFrame(d_results)
    df_clusters_metrics_html = df_clusters_metrics.to_html(index=False)

    data_clusters_sequences = {
        'plot': f"{basename}_figures/clusters_metrics.png",
        'dataframe': df_clusters_metrics_html
    }
    
    return data_clusters_sequences
    

def reports_clusters_labels(d_homogeneity, d_clst_caracteristics, basename):
    """
    Report on clusters labels

    Parameters
    ----------
    d_homogeneity : DICT
        Key: annotation type name
        Value: DICT
            cluster_id: list of cluster identifiers
            homogeneity_score: list of homogeneity scores
            seq_annot: list of annotated sequences
            number_of_label: list of number of annotations per cluster
            prop_annot: list of proportion of sequences annotated by clusters
            cluster_size: list of cluster sizes
            seq_unannot: list of number of unannotated sequences per cluster
            prop_unannot: list of proportion of unannotated sequences per cluster
    d_clst_caracteristics : DICT
        Key: annotation type name
        Value: DICT
            clst_annot: list of clusters with at least one annotated sequence
            clst_unannot: list of clusters with no annotated sequence
    basename : STR
        Network file name
        
    Returns
    -------
    data_clusters_labels : DICT
        plot1: figure in png format
        dataframe1: dataframe in HTML format
        plot2: figure in png format
        dataframe2: dataframe in HTML format

    """
    data_clusters_labels = dict()

    for label, d_metrics in d_homogeneity.items():
                
        d_caracteristics = d_clst_caracteristics[label]
        
        ######################################
        ##### Caracterisique des cluster #####
        ######################################
        
        fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(15, 5))
        sns.set_theme(style="ticks")
        sns.despine(fig)
        
        sns.histplot(
            x=d_caracteristics["clst_annot"],
            kde = True,
            ax=axes[0]
        )
        axes[0].set_title("Figure 4")
        axes[0].set_xlabel("Number of cluster annotated")
        axes[0].set_ylabel("Frequency")
        
        sns.histplot(
            x=d_caracteristics["clst_unannot"],
            kde = True,
            ax=axes[1]
        )
        axes[1].set_title("Figure 5")
        axes[1].set_xlabel("Number of cluster unannotated")
        axes[1].set_ylabel("Frequency")

        plt.savefig(f"{basename}_figures/clusters_caracteristics_{label}.png", format="png")

        plt.tight_layout()    
        
        if len(d_caracteristics["clst_annot"]) == 0:
            mean_annot = "NA"
            median_annot = "NA"
            max_annot = "NA"
            min_annot = "NA"
        else:
            mean_annot = np.round(np.mean(d_caracteristics["clst_annot"]), 3)
            median_annot = np.round(np.median(d_caracteristics["clst_annot"]), 3)
            max_annot = np.max(d_caracteristics["clst_annot"]).astype(int)
            min_annot = np.min(d_caracteristics["clst_annot"]).astype(int)
            
        if len(d_caracteristics["clst_unannot"]) == 0:
           mean_unannot = "NA"
           median_unannot="NA"
           max_unannot="NA"
           min_unannot="NA"
        else:
            mean_unannot = np.round(np.mean(d_caracteristics["clst_unannot"]), 3)
            median_unannot = np.round(np.median(d_caracteristics["clst_unannot"]), 3)
            max_unannot = np.max(d_caracteristics["clst_unannot"]).astype(int)
            min_unannot = np.min(d_caracteristics["clst_unannot"]).astype(int)

        d_results = {
            "Statistics": [
                "Number of cluster", "Cluster size mean", "Cluster size median", 
                "Cluster size max", "Cluster size min"
                ],
            "Cluster annotated": [
                str(len(d_caracteristics["clst_annot"])),
                str(mean_annot),
                str(median_annot),
                str(max_annot),
                str(min_annot)
                ],
            "Cluster unannotated": [
                str(len(d_caracteristics["clst_unannot"])),
                str(mean_unannot),
                str(median_unannot),
                str(max_unannot),
                str(min_unannot)
                ]
            }

        df_caracteristics = pd.DataFrame(d_results)
        df_caracteristics_html = df_caracteristics.to_html(index=False)

        ###################################
        ##### Homogeneité des cluster #####
        ###################################
                
        fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(15, 5))
        sns.set_theme(style="ticks")
        sns.despine(fig)

        sns.histplot(
            x=d_metrics["homogeneity_score"],
            kde = True,
            ax=axes[0]
        )
        axes[0].set_title("Figure 6")
        axes[0].set_xlabel("Homogeneity score")
        axes[0].set_ylabel("Frequency")
        
        sns.scatterplot(
            x=d_metrics["homogeneity_score"],
            y=d_metrics["cluster_size"],
            ax=axes[1]
        )
        axes[1].set_title("Figure 7")
        axes[1].set_xlabel("Homogeneity score")
        axes[1].set_ylabel("Cluster size")
        
        sns.scatterplot(
            x=d_metrics["homogeneity_score"],
            y=d_metrics["prop_annot"],
            ax=axes[2]
        )
        axes[2].set_title("Figure 8")
        axes[2].set_xlabel("Homogeneity score")
        axes[2].set_ylabel("Proportion of annotated sequence")
        
        plt.savefig(f"{basename}_figures/homogeneity_score_{label}.png", format="png")
        
        plt.tight_layout()

        d_results = {
            "Statistics": ["Mean", "Median", "Max", "Min"],
            "Proportion of annotated sequence": [
                str(np.round(np.mean(d_metrics["prop_annot"]), 3)),
                str(np.round(np.median(d_metrics["prop_annot"]), 3)),
                str(np.max(d_metrics["prop_annot"]).astype(int)),
                str(np.min(d_metrics["prop_annot"]).astype(int))
                ],
            "Homogeneity score": [
                str(np.round(np.mean(d_metrics["homogeneity_score"]), 3)),
                str(np.round(np.median(d_metrics["homogeneity_score"]), 3)),
                str(np.max(d_metrics["homogeneity_score"]).astype(int)),
                str(np.min(d_metrics["homogeneity_score"]).astype(int))
                ]
            }
        
        df_homogeneity = pd.DataFrame(d_results)
        df_homogeneity_html = df_homogeneity.to_html(index=False)
        
        name = ' '.join(label.split('_'))
        data_clusters_labels[name] = {
            "plot1": f"{basename}_figures/clusters_caracteristics_{label}.png",
            "dataframe1": df_caracteristics_html,
            "plot2": f"{basename}_figures/homogeneity_score_{label}.png",
            "dataframe2": df_homogeneity_html
            }

    return data_clusters_labels


if __name__ == '__main__':
    args = get_args()
    main(args)