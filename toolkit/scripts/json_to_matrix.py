#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  7 15:14:52 2025

@author: jrousseau
"""


from argparse import ArgumentParser
import json


def main(args):
    
    with open(f"{args.json}", "r") as f_json:
        d_matrice = json.load(f_json)
    
    d_labels, d_abundance = dict_labels_abundance(d_matrice)
    l_labels = list_labels(d_matrice)
    header, d_pos_label = prepare_header(l_labels)

    d_cluster_labels = dict()
    for cluster, d_abundance in d_matrice.items():
        d_cluster_labels[cluster] = set(d_abundance.keys())
    
    output = open(f"{args.basename}.tsv", "w")
    
    output.write('\t'.join(header) + '\n')
    
    for cluster, s_abundance in d_cluster_labels.items():
        print(cluster)
        d_clst_abundance = d_matrice[cluster]
        matrice = [cluster] + [str(d_clst_abundance.get(label, 0)) if label in s_abundance else "0" for label in d_pos_label] 
        output.write('\t'.join(matrice) + '\n')
    
    output.close()


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-j", "--json", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    parser.add_argument("-b", "--basename", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    return parser.parse_args()


def dict_labels_abundance(d_matrice):
    """
    

    Parameters
    ----------
    d_matrice : TYPE
        DESCRIPTION.

    Returns
    -------
    d_labels : TYPE
        DESCRIPTION.
    d_abundance : TYPE
        DESCRIPTION.

    """
    d_labels = dict()
    d_abundance = dict()
    
    for key, value in d_matrice.items():
        l_labels = value.keys()
        d_labels[key] = set(l_labels)
        for label in l_labels:
            abundance = f"{key}_{label}"
            d_abundance[abundance] = value[label]
    
    return d_labels, d_abundance


def list_labels(d_matrice):
    """
    

    Parameters
    ----------
    d_matrice : TYPE
        DESCRIPTION.

    Returns
    -------
    l_labels : TYPE
        DESCRIPTION.

    """
    s_labels = set()
    
    for key_nodes, value in d_matrice.items():
        for key_labels in value.keys():
            s_labels.add(key_labels)
    
    l_labels = sorted(s_labels)
    
    return l_labels


def prepare_header(l_labels):
    """
    

    Parameters
    ----------
    l_labels : TYPE
        DESCRIPTION.

    Returns
    -------
    header : TYPE
        DESCRIPTION.
    d_pos_label : TYPE
        DESCRIPTION.

    """
    header = ["cluster_id"]
    d_pos_label = dict()
    for position, label in enumerate(l_labels):
        header.append(label)
        d_pos_label[label] = position
    
    return header, d_pos_label


if __name__ == '__main__':
    args = get_args()
    main(args)