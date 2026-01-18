#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 15 09:47:14 2026

@author: jrousseau
"""


from datetime import date
from pathlib import Path
from argparse import ArgumentParser
import matplotlib.colors as mcolors
import matplotlib.lines as mlines
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import igraph as ig
import pandas as pd


def main(args):
    """
    

    Parameters
    ----------
    args : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    Path(f"cluster{args.id}_outputs").mkdir(parents=True, exist_ok=True)
    
    output = f"cluster{args.id}_outputs"
    output_edges = f"{output}/cluster{args.id}_graph_edges.tsv"
    output_cluster = f"{output}/cluster{args.id}_details.tsv"
    output_sequences = f"{output}/sequences_details_cluster{args.id}.tsv"
    output_visualization = f"{output}/cluster{args.id}_visualization.png"
    
    d_clusters_metrics = clusters_metrics(args.clstM)
    d_clusters_annotations = clusters_annotations(args.clstA)
    d_sequences_metrics, header_metrics = sequences_metrics(args.seqM)
    d_sequences_annotations, header_annotation = sequences_annotations(args.seqA)
    d_edges = network_edges(args.edges)

    retrieve_cluster_edges(output_edges, args.id, d_edges)
    retrieve_cluster_data(output_cluster, args.id, d_clusters_metrics, d_clusters_annotations)
    retrieve_sequences_data(output_sequences, args.id, d_sequences_metrics, d_sequences_annotations, header_metrics, header_annotation)

    graph = igraph_network(output_edges, args.id)
    graph_visualization(output_visualization, args.id, graph)
    graph_with_color(output, args.id, graph)


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(
        description="")

    parser.add_argument("-cA", "--clstA", type=str,
                        help="TSV file containing annotations or labels associated with clusters. Example: network_I14_clusters_annotations.tsv",
                        required=True)

    parser.add_argument("-cM", "--clstM", type=str,
                        help="TSV file containing metrics associated with clusters. Example: network_I14_clusters_metrics.tsv",
                        required=True)
    
    parser.add_argument("-sA", "--seqA", type=str,
                        help="TSV file containing annotations or labels associated with sequences. Example: network_I14_sequences_annotations.tsv",
                        required=True)
    
    parser.add_argument("-sM", "--seqM", type=str,
                        help="TSV file containing metrics associated with sequences. Example: network_I14_sequences_metrics.tsv",
                        required=True)

    parser.add_argument("-e", "--edges", type=str,
                        help="TSV file containing edges associated with the network. Example: network_I14_edges.tsv",
                        required=True)
    
    parser.add_argument("-i", "--id", type=str,
                        help="Cluster id",
                        required=True)

    return parser.parse_args()


def clusters_metrics(f_clusters_metrics):
    """
    

    Parameters
    ----------
    f_clusters_metrics : TYPE
        DESCRIPTION.

    Returns
    -------
    d_clusters_metrics : TYPE
        DESCRIPTION.

    """
    d_clusters_metrics = dict()
    
    with open(f_clusters_metrics, "r") as file:
        for position, row in enumerate(file):
            l_row = row.rstrip("\n").split('\t')
            if position == 0:
                header_metrics = l_row
            elif position != 0:
                d_clusters_metrics[l_row[0]] = dict()
                for position, column in enumerate(header_metrics):
                    if position != 0:
                        d_clusters_metrics[l_row[0]][column] = l_row[position]
                        
    return d_clusters_metrics


def clusters_annotations(f_clusters_annotations):
    """
    

    Parameters
    ----------
    f_clusters_annotations : TYPE
        DESCRIPTION.

    Returns
    -------
    d_clusters_annotations : TYPE
        DESCRIPTION.

    """
    d_clusters_annotations = dict()
    
    with open(f_clusters_annotations, "r") as file:
        for position, row in enumerate(file):
            l_row = row.rstrip("\n").split('\t')
            if position == 0:
                header_metrics = l_row
            elif position != 0:
                d_clusters_annotations[l_row[0]] = dict()
                for position, column in enumerate(header_metrics):
                    if position != 0:
                        d_clusters_annotations[l_row[0]][column] = l_row[position]

    return d_clusters_annotations


def sequences_metrics(f_sequences_metrics):
    """
    

    Parameters
    ----------
    f_sequences_metrics : TYPE
        DESCRIPTION.

    Returns
    -------
    d_sequences_metrics : TYPE
        DESCRIPTION.
    header_metrics : TYPE
        DESCRIPTION.

    """
    d_sequences_metrics = dict()
    
    with open(f_sequences_metrics, "r") as file:
        for position, row in enumerate(file):
            l_row = row.rstrip("\n").split('\t')
            if position == 0:
                header_metrics = l_row
            elif position != 0:
                if l_row[1] not in d_sequences_metrics:
                    d_sequences_metrics[l_row[1]] = dict()
                d_sequences_metrics[l_row[1]][l_row[0]] = dict()
                for position, column in enumerate(header_metrics):
                    if position != 0 and position != 1:
                        d_sequences_metrics[l_row[1]][l_row[0]][column] = l_row[position]
    header_metrics = header_metrics[2:]
    return d_sequences_metrics, header_metrics


def sequences_annotations(f_sequences_annotations):
    """
    

    Parameters
    ----------
    f_sequences_annotations : TYPE
        DESCRIPTION.

    Returns
    -------
    d_sequences_annotations : TYPE
        DESCRIPTION.
    header_annotation : TYPE
        DESCRIPTION.

    """
    d_sequences_annotations = dict()
    
    with open(f_sequences_annotations, "r") as file:
        for position, row in enumerate(file):
            l_row = row.rstrip("\n").split('\t')
            if position == 0:
                header_annotation = l_row
            elif position != 0:
                d_sequences_annotations[l_row[0]] = dict()
            
                for position, column in enumerate(header_annotation):
                    if position != 0 :
                        d_sequences_annotations[l_row[0]][column] = l_row[position]
          
    header_annotation = header_annotation[1:]
    return d_sequences_annotations, header_annotation


def network_edges(f_network_edges):
    """
    

    Parameters
    ----------
    f_network_edges : TYPE
        DESCRIPTION.

    Returns
    -------
    d_edges : TYPE
        DESCRIPTION.

    """
    d_edges = dict()
                
    with open(f_network_edges, "r") as file:
        for position, row in enumerate(file):
            l_row = row.rstrip("\n").split('\t')
            
            clst_id = l_row.pop()
            t_row = tuple(l_row)
            
            d_edges.setdefault(clst_id, []).append(t_row)
                
    return d_edges


def retrieve_cluster_edges(output_edges, cluster_id, d_edges):
    """
    

    Parameters
    ----------
    output_edges : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    d_edges : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    f_edges = open(output_edges, "w")

    f_edges.write(f"# Cluster {cluster_id} edges/alignments data file" + "\n")
    f_edges.write(f"# Contains information about connections and alignments" + "\n")
    f_edges.write(f"# Generated on: {date.today()}" + "\n\n")

    l_edges = d_edges[cluster_id]
    for edges in l_edges:        
        f_edges.write('\t'.join(edges) + '\n')
    f_edges.close()


def retrieve_cluster_data(output_cluster, cluster_id, d_clusters_metrics, d_clusters_annotations):
    """
    

    Parameters
    ----------
    output_cluster : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    d_clusters_metrics : TYPE
        DESCRIPTION.
    d_clusters_annotations : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    f_clusters = open(output_cluster, "w")
    
    f_clusters.write(f"# Cluster {cluster_id} data file" + "\n")
    f_clusters.write(f"# Contains metrics and annotations" + "\n")
    f_clusters.write(f"# Generated on: {date.today()}" + "\n\n")
    
    d_metrics = d_clusters_metrics[cluster_id]
    d_annotations = d_clusters_annotations[cluster_id]
    
    for key, value in d_metrics.items():
    
        l_information = [key, value]
        
        f_clusters.write('\t'.join(l_information) + '\n')
    
    for key, value in d_annotations.items():
        
        l_information = [key, value]
        
        f_clusters.write('\t'.join(l_information) + '\n')
    
    
    f_clusters.close()


def retrieve_sequences_data(output_sequences, cluster_id, d_sequences_metrics, d_sequences_annotations, header_metrics, header_annotation):
    """
    

    Parameters
    ----------
    output_sequences : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    d_sequences_metrics : TYPE
        DESCRIPTION.
    d_sequences_annotations : TYPE
        DESCRIPTION.
    header_metrics : TYPE
        DESCRIPTION.
    header_annotation : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    d_metrics = d_sequences_metrics[cluster_id]
    s_sequence = set(d_metrics.keys())
    
    l_header = header_metrics + header_annotation
    
    d_information = {"sequence_id": l_header}
    
    for key, value in d_metrics.items():   
        l_information = list()
        for column in header_metrics:    
            l_information.append(value[column])
        d_information[key] = l_information
        
    for key, value in d_metrics.items():
        for column in header_annotation:
            d_information[key].append(d_sequences_annotations[key][column])
    
    
    
    f_sequences = open(output_sequences, "w")
    
    f_sequences.write(f"# Cluster {cluster_id} sequences and related information" + "\n")
    f_sequences.write(f"# Contains data about the elements present in the cluster" + "\n")
    f_sequences.write(f"# Generated on: {date.today()}" + "\n\n")
    
    for key, value in d_information.items():    
        l_information = [key] + value
        f_sequences.write('\t'.join(l_information) + '\n')
    
    f_sequences.close()


def igraph_network(output_edges, cluster_id):
    
    df = pd.read_csv(output_edges, sep="\t", header=None, skiprows=4)
    
    sources = df[0]
    targets = df[4]
    weight_cols = df.columns.difference([0, 4])
    weights = df[weight_cols]
    
    edges = list(zip(sources, targets))

    graph = ig.Graph.TupleList(
        edges,
        directed=False,      # True si graphe orienté
        edge_attrs={"weight": weights}
    )
    
    return graph


def graph_visualization(output_visualization, cluster_id, graph):
    """
    

    Parameters
    ----------
    output_visualization : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    graph : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    layout = graph.layout("auto")

    fig, ax = plt.subplots()
    ig.plot(graph, layout=layout, target=ax)
    
    plt.savefig(output_visualization, dpi=300, bbox_inches="tight")
    #plt.show()
    

def network_category(output_label_visualization, cluster_id, selection, graph, label):
    """
    

    Parameters
    ----------
    output_label_visualization : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    selection : TYPE
        DESCRIPTION.
    graph : TYPE
        DESCRIPTION.
    label : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    # valeurs uniques
    unique_labels = sorted(set(selection))
    
    # créer une palette
    cmap = cm.get_cmap("tab10", len(unique_labels))

    # dictionnaire label -> couleur
    color_dict = {label: mcolors.to_hex(cmap(i)) for i, label in enumerate(unique_labels)}

    # attribuer la couleur à chaque nœud
    graph.vs["color"] = [color_dict[l] for l in selection]


    layout = graph.layout("auto")
    
    fig, ax = plt.subplots(figsize=(7,7))
    
    ig.plot(
        graph,
        target=ax,
        layout=layout,
        vertex_size=20  # pas de labels affichés
    )
    
    # créer la légende
    handles = [
        mlines.Line2D([], [], marker='o', linestyle='None', 
                      markersize=8, markerfacecolor=color, 
                      label=label)
        for label, color in color_dict.items()
    ]
    
    ax.legend(handles=handles, title="Label")
    title = f"Cluster {cluster_id} - Labels: {label} – nodes = {graph.vcount()}, edges = {graph.ecount()}"
    ax.set_title(title)
    
    plt.savefig(output_label_visualization, dpi=300, bbox_inches="tight")
    
    #plt.show()


def length_or_centrality(output_label_visualization, cluster_id, selection, graph, label):
    """
    

    Parameters
    ----------
    output_label_visualization : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    selection : TYPE
        DESCRIPTION.
    graph : TYPE
        DESCRIPTION.
    label : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    # Choisir une palette
    cmap = cm.get_cmap("viridis")  # du bleu au jaune
    
    # Normaliser les valeurs entre 0 et 1
    min_val = min(selection)
    max_val = max(selection)
    normalized = [(v - min_val)/(max_val - min_val) for v in selection]
    
    # Convertir en couleurs hexadécimales
    colors = [mcolors.to_hex(cmap(v)) for v in normalized]
    
    
    # Appliquer au graphe
    graph.vs["color"] = colors
    
    
    layout = graph.layout("auto")
    
    fig, ax = plt.subplots(figsize=(7,7))
    
    ig.plot(
        graph,
        target=ax,
        layout=layout,
        vertex_size=20
    )
    
    # Créer une colorbar pour montrer l'échelle
    sm = plt.cm.ScalarMappable(cmap=cmap, norm=plt.Normalize(vmin=min_val, vmax=max_val))
    sm.set_array([])
    plt.colorbar(sm, ax=ax, label=f"{label}")
    
    title = f"Cluster {cluster_id} - Labels: {label} – nodes = {graph.vcount()}, edges = {graph.ecount()}"
    ax.set_title(title)
    
    plt.savefig(output_label_visualization, dpi=300, bbox_inches="tight")
    
    #plt.show()


def graph_with_color(output, cluster_id, graph):
    """
    

    Parameters
    ----------
    output : TYPE
        DESCRIPTION.
    cluster_id : TYPE
        DESCRIPTION.
    graph : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    labels_df = pd.read_csv(f"results_cluster_{cluster_id}/sequences_informations_{cluster_id}.tsv", sep="\t", skiprows=4)
    labels_df.fillna("unannotated", inplace=True)
    labels_df.set_index(labels_df.columns[0], inplace=True)
    
    l_labels = list(labels_df)
    
    node_names = graph.vs["name"]
    
    for col in labels_df.columns:
        graph.vs[col] = [labels_df.loc[n, col] if n in labels_df.index else None
                     for n in node_names]
    
    for label in l_labels:
        
        output_label_visualization = f"{output}/cluster{args.id}_{label}_visualization.png"

        
        graph.es["color"] = "#cccccc"
        selection = graph.vs[label]
        if label != "eigenvector_centrality" and label != "sequence_length":
            network_category(output_label_visualization, cluster_id, selection, graph, label)
        
        else:
            length_or_centrality(output_label_visualization, cluster_id, selection, graph, label)


if __name__ == '__main__':
    args = get_args()
    main(args)

# cluster_id = '0'

# f_clusters_annotations = "clusters/network_I14_clusters_annotations.tsv"
# f_clusters_metrics = "clusters/network_I14_clusters_metrics.tsv"

# f_network_edges = "edges/network_I14_edges.tsv"

# f_sequences_annotations = "sequences/network_I14_sequences_annotations.tsv"
# f_sequences_metrics = "sequences/network_I14_sequences_metrics.tsv"

# Path(f"cluster{cluster_id}_outputs").mkdir(parents=True, exist_ok=True)

# d_clusters_metrics = clusters_metrics(f_clusters_metrics)
# d_clusters_annotations = clusters_annotations(f_clusters_annotations)
# d_sequences_metrics, header_metrics = sequences_metrics(f_sequences_metrics)
# d_sequences_annotations, header_annotation = sequences_annotations(f_sequences_annotations)
# d_edges = network_edges(f_network_edges)

# retrieve_cluster_edges(cluster_id, d_edges)
# retrieve_cluster_data(cluster_id, d_clusters_metrics, d_clusters_annotations)
# retrieve_sequences_data(cluster_id, d_sequences_metrics, d_sequences_annotations, header_metrics, header_annotation)

# graph = igraph_network(cluster_id)
# graph_visualization(cluster_id, graph)
# graph_with_color(cluster_id, graph)



