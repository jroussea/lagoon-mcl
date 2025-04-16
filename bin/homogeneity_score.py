#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 27 15:58:43 2025

@author: jroussea
@date: 2025-03-03
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script calculates the homogeneity score
"""


from argparse import ArgumentParser
from collections import Counter
import os
import json


def main(args):
    """

    Parameters
    ----------
    args.network : TSV
        Network file
    args.basename : STR
        Network name
    args.labels : TSV
        Labels file

    """
    d_size = network_description(args.network)
    output_metrics, output_labels = output_file_preparation(d_size, args.basename)

    s_database = set()
    with open(args.labels, 'r') as f_labels:
        for label in f_labels:
            l_label = label.rstrip("\n").split('\t')
            if l_label[2] not in s_database:
                s_database.update({l_label[2]})

    for database in s_database:
        d_sequence = sequence_label(args.labels, database)
        d_network, d_label = network_information(args.network, d_sequence)
        d_network = homogeneity_score(d_network, d_label, "all")
        # d_network = homogeneity_score(d_network, d_label, "annot")
        save_homogeneity_score(output_metrics, d_network, database)
        write_labels_file(output_labels, d_network, database)
        abundance_matrix(d_network, database, args.basename)


def get_args():
    """

    Parse arguments

    """
    parser = ArgumentParser(description="This script calculates the homogeneity score")
    
    parser.add_argument("-l", "--labels", type = str,
                        help = "Labels file", 
                        required = True)

    parser.add_argument("-n", "--network", type = str,
                        help = "Network file", 
                        required = True)

    parser.add_argument("-b", "--basename", type = str,
                        help = "Network name", 
                        required = True)

    return parser.parse_args()


def network_description(network):
    """
    Number of nodes / sequences per cluster

    Parameters
    ----------
    network : TSV
        Network file

    Returns
    -------
    d_size : DICT
        Cluster size dictionary (number of nodes per cluster).
            Key: cluster identifier
            Value: cluster size

    """
    d_size = dict()

    with open(network, 'r') as f_network:
        
        for position, row in enumerate(f_network):
            if position != 0:
                l_row = row.strip().split("\t")
                if l_row[0] not in d_size.keys():
                    d_size[l_row[0]] = 1
                elif l_row[0] in d_size.keys():
                    d_size[l_row[0]] += 1
    
    return d_size


def output_file_preparation(d_size, basename):
    """
    Prepare the output form by entering the first two columns 
        column 1 [cluster_id]: cluster identifier
        column 2 [cluster_size]: cluster size (number of nodes)

    Parameters
    ----------
    d_size : DICT
        Cluster size dictionary (number of nodes per cluster).
            Key: cluster identifier
            Value: cluster size
    basename : STR
        Network file name

    Returns
    -------
    output : TSV
        Output file

    """
    output_metrics = f"{basename}_homogeneity_score.tsv"
    output_labels = f"{basename}_clusters_annotations.tsv"
    
    f_homogeneity = open(output_metrics, 'w')
    f_labels = open(output_labels, 'w')
    
    f_homogeneity.write("cluster_id\tcluster_size\n")
    f_labels.write("cluster_id\n")
    for key, value in d_size.items():
        f_homogeneity.write('\t'.join([str(key), str(value)]) + '\n')
        f_labels.write(f'{str(key)}\n')
    
    f_labels.close()
    f_homogeneity.close()

    return output_metrics, output_labels


def sequence_label(labels, database):
    """
    Dictionary of annotations for each sequence

    Parameters
    ----------
    labels : TSV
        Annotation file
    database : STR
        database under analysis (e.g. FunFam, Pfam, Gene3D).

    Returns
    -------
    d_sequence : DICT
        Key: sequence ID.
        Value: list of all labels linked to the sequence.

    """
    d_sequence = dict()
    with open(labels, 'r') as f_labels:
        for row in f_labels:
            l_row = row.rstrip("\n").split('\t')
            if l_row[2] == database and l_row[1] != "NA":
                if l_row[0] not in d_sequence.keys():
                    d_sequence[l_row[0]] = l_row[1].split(";")
                else:
                    d_sequence[l_row[0]].append(l_row[1].split(";"))
    
    return d_sequence


def network_information(network, d_sequence):
    """
    Network descriptions 

    Parameters
    ----------
    network : TSV
        Network file
    d_sequence : DICT
        Key: sequence ID.
        Value: list of all labels linked to the sequence.

    Returns
    -------
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : DICT
            protein_accession: list of all nodes
            label: list of sequences with at least one label
            sequence_annotated: number of sequences with at least one label
    d_label : DICT
        Key: cluster ID.
        Value: set of all labels composing the cluser.

    """
    d_network = dict()
    d_label = dict()

    with open(network, 'r') as f_network:
        for position, row in enumerate(f_network):
            if position != 0:
                l_row = row.strip().split('\t')
                    
                ############################
                #### Dictionary d_label ####
                ############################
                
                if l_row[0] not in d_label:
                    d_label[l_row[0]] = {}
                if l_row[1] in d_sequence:
                    l_label = str(d_sequence[l_row[1]][0]).split(";")
                    for label in set(l_label):
                        if label not in d_label[l_row[0]]:
                            d_label[l_row[0]][label] = {l_row[1]}
                        else:
                            d_label[l_row[0]][label].add(l_row[1])
                            
                ##############################
                #### Dictionary d_network ####
                ##############################
                
                if l_row[0] not in d_network and l_row[1] in d_sequence:
                    # si le cluster n'a pas encore été vu et que la séquence 
                    d_network[l_row[0]] = {'protein_accession': [l_row[1]],
                                            'label': d_sequence[l_row[1]],
                                            'all_label': d_sequence[l_row[1]],
                                            'sequence_annotated': 1}
        
                elif l_row[0] not in d_network and l_row[1] not in d_sequence:
                    d_network[l_row[0]] = {'protein_accession': [l_row[1]],
                                            'label': [],
                                            'all_label': [],
                                            'sequence_annotated': 0}
        
                elif l_row[0] in d_network and l_row[1] in d_sequence:
                    d_network[l_row[0]]['protein_accession'].append(l_row[1])
                    d_network[l_row[0]]['label'] = d_network[l_row[0]]['label'] + d_sequence[l_row[1]]
                    d_network[l_row[0]]['all_label'] = d_network[l_row[0]]['all_label'] + d_sequence[l_row[1]]
                    d_network[l_row[0]]['sequence_annotated'] += 1
        
                elif l_row[0] in d_network and l_row[1] not in d_sequence:
                    d_network[l_row[0]]['protein_accession'].append(l_row[1])
    
    return d_network, d_label


def negative_homogeneity_score(d_label, key):
    """
    Recalculates homogeneity score when negative

    Parameters
    ----------
    d_label : DICT
        Key: cluster ID.
        Value: set of all labels composing the cluser.
    key : STR
        Cluster ID

    Returns
    -------
    l_label_select : LIST
        List of selected labels

    """
    l_label_select = list()
    
    s_sequence = set()
    
    d_cluster_label = d_label[key]
    
    d_cluster_label_size = dict()
    
    for label in d_cluster_label:
        d_cluster_label_size[label] = len(d_cluster_label[label])
        s_sequence = s_sequence | d_cluster_label[label]
    
    while len(s_sequence) > 0:
        
        max_label = max(d_cluster_label_size, key=d_cluster_label_size.get)
        
        l_label_select.append(max_label)
        s_sequence = s_sequence - d_cluster_label[max_label]
        
        d_cluster_label = {key:value - d_cluster_label[max_label] for key, value in d_cluster_label.items()}
        
        for label in d_cluster_label:
            d_cluster_label_size[label] = len(d_cluster_label[label])
    
    return l_label_select


def homogeneity_score(d_network, d_label, homogeneity_score):
    """
    Calculate homogeneity score

    Parameters
    ----------
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : DICT
            protein_accession: list of all nodes
            label: list of sequences with at least one label
            sequence_annotated: number of sequences with at least one label
    d_label : DICT
        Key: cluster ID.
        Value: set of all labels composing the cluser.
    homogeneity_score : STR
        all or annot: in progress.

    Returns
    -------
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : DICT
            protein_accession: list of all nodes
            label: list of sequences with at least one label
            sequence_annotated: number of sequences with at least one label
            homogenity_score_{homogeneity score variable}: homogeneity score value

    """
    for key in d_network:
        
        if homogeneity_score == "all":
            divisor = len(set(d_network[key]["protein_accession"]))
        elif homogeneity_score == "annot":
            divisor = d_network[key]["sequence_annotated"]
        s_key = f"homogeneity_score_{homogeneity_score}"
        
        d_network[key]["label"] = list(set(d_network[key]["label"])) 

        if len(d_network[key]["label"]) == 1:
            d_network[key][s_key] = 1
            
            
            
        elif len(d_network[key]["label"]) > 1:
        
            hom_sc = 1 - (len(set(d_network[key]["label"])) / divisor)

            if hom_sc < 0:
                l_label_select = negative_homogeneity_score(d_label, key)
                
                hom_sc = 1 - (len(set(l_label_select)) / len(set(d_network[key]["protein_accession"])))
                
            d_network[key][s_key] = hom_sc
            
        else:
            d_network[key][s_key] = 'NA'

    return d_network


def save_homogeneity_score(output_metrics, d_network, database):
    """
    Write cluster metrics file

    Parameters
    ----------
    output : TSV
        Output file
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : DICT
            protein_accession: list of all nodes
            label: list of sequences with at least one label
            sequence_annotated: number of sequences with at least one label
            homogenity_score_{homogeneity score variable}: homogeneity score value
    database : STR
        database under analysis (e.g. FunFam, Pfam, Gene3D).

    Returns
    -------
    None.

    """
    with open(output_metrics, 'r') as f_input:
        with open('temporary', 'w') as f_temp:
            for position, row in enumerate(f_input):
                if position == 0:
                    modified_row = row.strip() + f"\t{database}_homogeneity_score\t{database}_sequence\t{database}_numbre_labels\n"
                else:
                    l_row = row.strip().split("\t")
                    homsc = str(d_network[l_row[0]]["homogeneity_score_all"])
                    seq = str(d_network[l_row[0]]["sequence_annotated"])
                    labels = str(len(set(d_network[l_row[0]]["label"])))
                    modified_row = row.strip() + f"\t{homsc}\t{seq}\t{labels}\n"
                
                f_temp.write(modified_row)

    os.replace("temporary", output_metrics)


def write_labels_file(output_labels, d_network, database):
    """
    Writes a file containing a list of all labels/annotations that can be found in a cluster

    Parameters
    ----------
    d_network : DICT
        Clé : Identifiant des cluster
        Valeur : DICT
            protein_accession: list of all nodes
            label: list of sequences with at least one label
            sequence_annotated: number of sequences with at least one label
            homogenity_score_{homogeneity score variable}: homogeneity score value
    database : STR
        database under analysis (e.g. FunFam, Pfam, Gene3D).
    basename : STR
        Network file name

    Returns
    -------
    None.

    """
    with open(output_labels, "r") as f_input:
        with open("temporary", "w") as f_temp:
            for position, row in enumerate(f_input):
                if position == 0:
                    modified_row = row.strip() + f"\t{database}\n"
                else:
                    l_row = row.strip().split("\t")
                    labels = set(d_network[l_row[0]]["label"])
                    if len(labels) == 0:
                        labels = set(["NA"])
                    modified_row = row.strip() + f"\t{';'.join(labels)}\n"
                f_temp.write(modified_row)

    os.replace("temporary", output_labels)


def abundance_matrix(d_network, database, basename):
    
    d_abundance = dict()
    for key, value in d_network.items():
        if value["all_label"]:
            d_abundance[key] = dict(Counter(value["all_label"]))

    with open(f"{basename}_{database}_abundance_matrix.json", "w") as f_output:
        json.dump(d_abundance, f_output)


if __name__ == '__main__':
    args = get_args()
    main(args)