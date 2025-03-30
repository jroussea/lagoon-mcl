#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  7 11:29:54 2025

@author: jrousseau
"""

from argparse import ArgumentParser
import igraph as ig
import pandas as pd
import math
import json


def main(args):

    igraph_edge = f"edges_igraph_{args.basename}.tsv"
    igraph_node = f"nodes_igraph_{args.basename}.tsv"
    
    d_sequence = igraph_file_preparation(args.network, igraph_edge, igraph_node)
    g_decompose = load_graph(igraph_edge, igraph_node)
    d_centrality, d_diameter = dict_eigenvector_centrality(g_decompose)
    d_alphafold = dict_alphafold_id(args.alphafold)
    write_nodes_files(args.information, args.basename, d_alphafold, d_sequence, d_centrality)
    
    with open(f"diameter_{args.basename}.json", "w") as f_json:        
        json.dump(d_diameter, f_json)


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-i", "--information", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-a", "--alphafold", type = str,
                        help = "cluster size min", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "cluster size min", 
                        required = True)
    
    return parser.parse_args()


def igraph_file_preparation(network, igraph_edge, igraph_node):
    """
    

    Parameters
    ----------
    network : TYPE
        DESCRIPTION.
    igraph_edge : TYPE
        DESCRIPTION.
    igraph_node : TYPE
        DESCRIPTION.

    Returns
    -------
    d_sequence : TYPE
        DESCRIPTION.

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
    

    Parameters
    ----------
    igraph_edge : TYPE
        DESCRIPTION.
    igraph_node : TYPE
        DESCRIPTION.

    Returns
    -------
    d_centrality : TYPE
        DESCRIPTION.

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


def dict_alphafold_id(alphafold):
    
    d_alphafold = dict()
    
    with open(alphafold, "r") as f_alphafold:
        for position, row in enumerate(f_alphafold):
            l_row = row.strip().split("\t")
            if position != 0:
                d_alphafold[l_row[0]] = (l_row[2], l_row[3], l_row[4], l_row[5])
    
    return d_alphafold


def write_nodes_files(information, basename, d_alphafold, d_sequence, d_centrality):
    
    f_metrics = open(f"nodes_metrics_{basename}.tsv", "w")
    f_labels = open(f"nodes_labels_{basename}.tsv", "w")
    
    with open(information, "r") as f_input:
    
        for position, row in enumerate(f_input):
            l_row = row.strip().split("\t")
            
            metrics = l_row[:3] # récupérer les deux première colonnes du fichier
            labels = l_row[3:] # récupérer les colonne de la position 3 à la fin
    
            if position == 0:
                new_labels = list()
                for i in labels:
                    new_labels.append(f"num_{i}_id")
                #col_metrics = ["eigenvector_centrality"] + new_labels + ["alphafold_id", "alphafold_clst_id", "num_alphafold_pfam_id"]
                col_metrics = ["eigenvector_centrality"] + new_labels + ["alphafold_id", "alphafold_clst_id"]
                #col_labels = labels + ["alphafold_id", "alphafold_clst_id", "alphafold_pfam_id"]
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
                
                if d_alphafold[l_row[0]][2] == "NA":
                    num_af_pfam = 0
                else:
                    num_af_pfam = len(d_alphafold[l_row[0]][2].split(";"))
                
                #col_metrics = [str(d_centrality[node_id])] + num_label + [d_alphafold[l_row[0]][0], d_alphafold[l_row[0]][1], str(num_af_pfam)]
                col_metrics = [str(d_centrality[node_id])] + num_label + [d_alphafold[l_row[0]][0], d_alphafold[l_row[0]][1]]
                #col_labels = labels + [d_alphafold[l_row[0]][0], d_alphafold[l_row[0]][1], d_alphafold[l_row[0]][2]]
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


