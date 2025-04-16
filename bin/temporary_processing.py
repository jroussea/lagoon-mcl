#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Apr 15 09:05:08 2025

@author: jrousseau
"""

from Bio import SeqIO
from argparse import ArgumentParser
import os

def main(args):
    """

    """
    d_network, d_hash = dict_network(args.network)
    d_length = sequence_length(args.fasta)
    output = output_file(args.basename, d_network, d_length)
    d_labels = dict_labels_nodes_processing(args.labels, d_hash)
    write_temporary_file(output, d_labels, d_hash)


def get_args():
    """

    Parse arguments
    
    """
    parser = ArgumentParser(description="This script is used to prepare fasta sequences for LAGOON-MCL")
    
    parser.add_argument("-f", "--fasta", type = str,
                        help = "Input fasta file", 
                        required = False)

    parser.add_argument("-l", "--labels", type = str,
                        help = "Annotation files", 
                        required = False)


    parser.add_argument("-n", "--network", type = str,
                        help = "Network file", 
                        required = False)

    parser.add_argument("-b", "--basename", type = str,
                        help = "Network name", 
                        required = False)

    return parser.parse_args()



def dict_network(network):
    """
    Create a dictionary from the TSV file containing the network

    Parameters
    ----------
    label : TSV
        TSV file with 2 columns containing the network

    Returns
    -------
    d_network : DICT
        Key: sequence ID.
        Value: cluster IS
    d_hash : DICT
        Key: sequence ID
        Value: New sequence ID (0, 1, 2, 3, etc.)

    """
    d_network = dict()
    d_hash = dict()

    with open(network, "r") as f_network:
        for position, row in enumerate(f_network):
            if position != 0:
                l_row = row.strip().split("\t")
                d_network[l_row[1]] = l_row[0]
                d_hash[l_row[1]] = position-1
    
    return d_network, d_hash


def dict_labels_nodes_processing(labels, d_hash):
    """
    Create a set of all labels / annotations

    Parameters
    ----------
    label : TSV
        TSV file with 2 columns containing the network

    Returns
    -------
    d_label : DICT
        Key: database/annotation
        Value: DICT
            Key: sequence ID (0,1,2,3, etc.)
            Value: Annotations

    """
    d_labels = dict()

    with open(labels, "r") as f_labels:
        for position, row in enumerate(f_labels):
            l_row = row.strip().split("\t")
            if l_row[0] in d_hash.keys():
                if l_row[2] not in d_labels.keys():
                    d_labels[l_row[2]] = {d_hash[l_row[0]]: l_row[1]}
                else:
                    d_labels[l_row[2]][d_hash[l_row[0]]] = l_row[1]
    
    return d_labels


def output_file(basename, d_network, d_length):
    """
    Prépare les fichiers de sortie 

    Parameters
    ----------
    basename : STR
        Network name
    d_network : DICT
        network dictionary
    d_length : DICT
        dictionary of sequence length (in amino acids)

    Returns
    -------
    output : TSV
        Output file

    """
    output = f"{basename}_sequences_annotations_preprocessing.tsv"
    
    f_output = open(output, "w")
    
    f_output.write('\t'.join(["sequence_id", "cluster_id", "sequence_length"]) + '\n')
    
    for sequence_id, cluster_id in d_network.items():
        f_output.write('\t'.join([sequence_id, cluster_id, str(d_length[sequence_id])]) + '\n')
    
    f_output.close()
    
    return output


def sequence_length(fasta):
    """
    Calculate sequence length (in amino acids)

    Parameters
    ----------
    fasta : FASTA
        Fasta file

    Returns
    -------
    d_length : DICT
        Sequence length dictionary

    """

    return {record.id: len(record.seq) for record in SeqIO.parse(fasta, "fasta")}


def write_temporary_file(output, d_labels, d_hash):
    """
    Calculate sequence length (in amino acids)

    Parameters
    ----------
    d_label : DICT
        Key: database/annotation
        Value: DICT
            Key: sequence ID (0,1,2,3, etc.)
            Value: Annotations
    output : TSV
        Output file
    d_hash : DICT
        Key: sequence ID
        Value: New sequence ID (0, 1, 2, 3, etc.)

    Returns
    -------
    None.

    """
    for database, dictionary in d_labels.items():
        print(database)
        with open(output, "r") as f_output:
            with open("temporary", "w") as f_tmp:
                for position, row in enumerate(f_output):
                    l_row = row.strip().split("\t")
                    if position == 0:
                        modified_row = l_row + [f"{database}"]
                        f_tmp.write('\t'.join(modified_row)+ '\n')
                    else:
                        labels = dictionary[d_hash[l_row[0]]]
                        modified_row = l_row + [labels]
                        f_tmp.write('\t'.join(modified_row) + '\n')
    os.replace("temporary", output)        

if __name__ == '__main__':
    args = get_args()
    main(args)


# network = "network_I4.tsv"
# fasta = "fasta_sequences_renamed.fasta"
# basename = "network_I4"
# labels = "all_sequence_annotations.tsv"
    

# d_network, d_hash = dict_network(network)
# d_length = sequence_length(fasta)
# output = output_file(basename, d_network, d_length)
# d_labels = dict_labels_nodes_processing(labels, d_hash)
# write_temporary_file(output, d_labels, d_hash)


# for database, dictionary in d_labels.items():
#     print(database)
#     with open(output, "r") as f_output:
#         with open("temporary", "w") as f_tmp:
#             for position, row in enumerate(f_output):
#                 l_row = row.strip().split("\t")
#                 if position == 0:
#                     modified_row = l_row + [f"{database}"]
#                     f_tmp.write('\t'.join(modified_row)+ '\n')
#                 else:
#                     labels = dictionary[d_hash[l_row[0]]]
#                     modified_row = l_row + [labels]
#                     f_tmp.write('\t'.join(modified_row) + '\n')
# os.replace("temporary", output)            
