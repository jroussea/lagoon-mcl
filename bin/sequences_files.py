#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  7 11:29:54 2025

@author: jrousseau
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script create sequence-specific files
"""

from argparse import ArgumentParser
import igraph as ig
import pandas as pd
import math
import json


def main(args):
    """

    Parameters
    ----------
    args.information : TSV
        File containing all sequence-related information
    args.network : TSV
        Network file
    args.basename : STR
        Network file name

    """
    igraph_edge = f"edges_igraph_{args.basename}.tsv"
    igraph_node = f"nodes_igraph_{args.basename}.tsv"
    
    d_sequence = igraph_file_preparation(args.network, igraph_edge, igraph_node)
    g_decompose = load_graph(igraph_edge, igraph_node)
    d_centrality, d_diameter = dict_eigenvector_centrality(g_decompose)
    write_nodes_files(args.information, args.basename, d_sequence, d_centrality)
    
    with open(f"{args.basename}_diameters.json", "w") as f_json:        
        json.dump(d_diameter, f_json)


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(description="This script create sequence-specific files")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network file", 
                        required = True)
    
    parser.add_argument("-i", "--information", type = str,
                        help = " File containing all sequence-related information", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network file name", 
                        required = True)
    
    return parser.parse_args()


def igraph_file_preparation(network, igraph_edge, igraph_node):
    """
    Preparing the files used by igraph-python

    Parameters
    ----------
    network : TYPE
        Network file.
    igraph_edge : TYPE
        File in igraph-python format containing network stops.
    igraph_node : TYPE
        File in igraph-python format containing nodes and network information.

    Returns
    -------
    d_sequence : DICT
        Key: sequence ID
        Value: sequence-specific numeric identifier used by igraph-python

    """
    f_nodes = open(igraph_node, "w")
    f_edges = open(igraph_edge, 'w')

    with open(network, 'r') as f_network:
        d_sequence = dict()
        
        count = 0

        for alignment in f_network:
            l_alignment = alignment.rstrip("\n").split('\t')

            if l_alignment[0] not in d_sequence:
                d_sequence[l_alignment[0]] = count
                l_nodes = [str(count), str(l_alignment[0]), str(l_alignment[14])]
                f_nodes.write('\t'.join(l_nodes) + '\n')
                count += 1
            if l_alignment[4] not in d_sequence:
                d_sequence[l_alignment[4]] = count
                l_nodes = [str(count), str(l_alignment[4]), str(l_alignment[14]),]
                f_nodes.write('\t'.join(l_nodes) + '\n')
                count += 1     
            
            if float(l_alignment[12]) == float(0):
                evalue = 200
            else:
                evalue = -math.log10(float(l_alignment[12]))
                if evalue >= 200:
                    evalue = 200
                    
            l_edges = [str(d_sequence[l_alignment[0]]), str(d_sequence[l_alignment[4]]), str(l_alignment[9]), str(evalue), str(l_alignment[13])]

            f_edges.write('\t'.join(l_edges) + '\n')

    f_edges.close()
    f_nodes.close()
    
    return d_sequence


def load_graph(igraph_edge, igraph_node):
    """
    Loading files used by igraph-python

    Parameters
    ----------
    igraph_edge : TYPE
        File in igraph-python format containing network stops.
    igraph_node : TYPE
        File in igraph-python format containing nodes and network information.

    Returns
    -------
    g_decompose: LIST
        list of all connected components

    """
    edges = pd.read_csv(igraph_edge, 
                        names = ['col1', 'col2', 'col3', 'col4', 'col5'], 
                        sep = "\t", header=None)
    vertices = pd.read_csv(igraph_node, 
                           names = ['colA', 'colB', 'colC'], 
                           sep = "\t", header=None)

    g = ig.Graph.DataFrame(edges, directed=False, vertices=vertices)

    g_decompose = g.decompose()

    return g_decompose


def dict_eigenvector_centrality(g_decompose):
    """
    Cluster metrics (node centrality and diameter)

    Parameters
    ----------
    g_decompose: LIST
        list of all connected components

    Returns
    -------
    d_centrality : DICT
        Key: sequence ID
        Value: sequence centrality
    d_diameter : DICT
        Key: cluster ID
        Value: cluster diameter

    """
    d_diameter = dict()
    d_centrality = dict()

    for cluster in g_decompose:
        cluster_id = list(set(cluster.vs['colC']))[0]
        d_diameter[cluster_id] = cluster.diameter()
        
        l_centrality = cluster.eigenvector_centrality(directed=False)
        
        for idx, node in enumerate(cluster.vs):

            d_centrality[node['colA']] = l_centrality[idx]

    return d_centrality, d_diameter


def write_nodes_files(information, basename, d_sequence, d_centrality):
    """
    Cluster metrics (node centrality and diameter)

    Parameters
    ----------
    information: TSV
        File containing all sequence-related information
    basename: STR
        Network file name
    d_centrality : DICT
        Key: sequence ID
        Value: sequence centrality
    d_diameter : DICT
        Key: cluster ID
        Value: cluster diameter

    Returns
    -------
    None.

    """
    f_metrics = open(f"{basename}_sequences_metrics.tsv", "w")
    f_labels = open(f"{basename}_sequences_annotations.tsv", "w")
    
    with open(information, "r") as f_input:
    
        for position, row in enumerate(f_input):
            l_row = row.strip().split("\t")
            
            metrics = l_row[:3] # retrieve the first two columns of the file
            labels = l_row[3:]  # retrieve columns from position 3 to the end
    
            if position == 0:
                new_labels = list()
                for i in labels:
                    new_labels.append(f"num_{i}_id")
                col_metrics = ["eigenvector_centrality"] + new_labels
                col_labels = labels
            else:
                node_id = d_sequence[metrics[0]]
                num_label = list()
                for i in labels:
                    if i == "NA":
                        num = 0
                    else:
                        num = len(i.split(";"))
                    num_label.append(str(num))
                
                col_metrics = [str(d_centrality[node_id])] + num_label
                col_labels = labels
            
            all_metrics = metrics + col_metrics
            f_metrics.write('\t'.join(all_metrics) + '\n')
    
            all_labels = [l_row[0]] + col_labels
            f_labels.write('\t'.join(all_labels) + '\n')
    
    f_labels.close()
    f_metrics.close()
        
        
if __name__ == '__main__':
    args = get_args()
    main(args)


