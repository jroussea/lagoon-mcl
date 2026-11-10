#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 16 12:32:23 2025

@author: jrousseau
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Extract the central sequence
"""


from argparse import ArgumentParser
from Bio import SeqIO


def main(args):
    """

    Parameters
    ----------
    args.sequences : TSV

    args.basename : STR
        Network file name

    """
    d_max_length = max_sequence_length(args.sequences)
    d_sequence = sequence_selection(args.sequences, d_max_length)
    s_clusters = unknown_clusters(args.clusters)
    s_all_sequences, s_unknown_sequences = write_files(d_sequence, s_clusters, args.basename)
    extract_fasta_sequences(args.fasta, s_all_sequences, s_unknown_sequences, args.basename)


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(description="This script create sequence-specific files")
    
    parser.add_argument("-s", "--sequences", type = str,
                        help = "Sequences file", 
                        required = True)
    
    parser.add_argument("-c", "--clusters", type = str,
                        help = "Clusters file", 
                        required = True)
    
    parser.add_argument("-f", "--fasta", type = str,
                        help = "Clusters file", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network file name", 
                        required = True)
    
    return parser.parse_args()


def max_sequence_length(df_metrics):
    """
    

    Parameters
    ----------
    df_metrics : TYPE
        DESCRIPTION.

    Returns
    -------
    d_max_length : TYPE
        DESCRIPTION.

    """
    d_sequence_length = dict()
    d_max_length = dict()

    with open(df_metrics, "r") as f_input:
        for position, sequence in enumerate(f_input):
            l_sequence = sequence.strip().split("\t")
            if position != 0:
                if l_sequence[1] not in d_sequence_length.keys():
                    d_sequence_length[l_sequence[1]] = [int(l_sequence[2])]
                else:
                    d_sequence_length[l_sequence[1]].append(int(l_sequence[2]))

    for key, value in d_sequence_length.items():
        max_length = max(value)
        d_max_length[key] = max_length
            
    return d_max_length


def sequence_selection(df_metrics, d_max_length):
    """
    

    Parameters
    ----------
    df_metrics : TYPE
        DESCRIPTION.
    d_max_length : TYPE
        DESCRIPTION.

    Returns
    -------
    d_sequence : TYPE
        DESCRIPTION.

    """
    d_sequence = dict()
    
    with open(df_metrics, "r") as f_input:
        
        for position, sequence in enumerate(f_input):
            l_sequence = sequence.strip().split("\t")
            if position != 0:
                norm_length = int(l_sequence[2]) / d_max_length[l_sequence[1]]
                combined_score = 0.6 * float(l_sequence[3]) + 0.4 * norm_length
                if l_sequence[1] not in d_sequence.keys():
                    d_sequence[l_sequence[1]] = {
                        "sequence_id": l_sequence[0],
                        "sequence_length": int(l_sequence[2]),
                        "eigenvector_centrality": float(l_sequence[3]),
                        "score": combined_score
                    }
                else:
                    if combined_score > d_sequence[l_sequence[1]]["score"]:

                        d_sequence[l_sequence[1]] = {"sequence_id": l_sequence[0],
                                                     "sequence_length": int(l_sequence[2]),
                                                     "eigenvector_centrality": float(l_sequence[3]),
                                                     "score": combined_score}

    return d_sequence


def unknown_clusters(clusters):
    """
    

    Parameters
    ----------
    clusters : TYPE
        DESCRIPTION.

    Returns
    -------
    s_clusters : TYPE
        DESCRIPTION.

    """
    s_clusters = set()
    
    with open(clusters, "r") as f_input:
        
        for position, cluster in enumerate(f_input):
            l_cluster = cluster.strip().split("\t")
            if position == 0:
                pos_pfam = l_cluster.index("pfamDB_homogeneity_score")
                pos_alphafold = l_cluster.index("alphafold_sequences_homogeneity_score")
            
            else:
                if l_cluster[pos_pfam] == "NA" and l_cluster[pos_alphafold] == "NA":
                    s_clusters.add(l_cluster[0])

    return s_clusters


def write_files(d_sequence, s_clusters, basename):
    """
    

    Parameters
    ----------
    d_sequence : TYPE
        DESCRIPTION.
    s_clusters : TYPE
        DESCRIPTION.
    basename : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    s_all_sequences = set()
    s_unknown_sequences = set()

    f_output = open(f"{basename}_central_sequence.txt", "w")
    f_output_all = open(f"{basename}_central_sequence_all_information.tsv", "w")
    f_output_unknown = open(f"{basename}_unknown_central_sequence.txt", "w")

    l_metrics = ["sequence_id", "cluster_id", "sequence_length",
                 "eigenvector_centrality", "combined_score"]

    for key, dict_value in d_sequence.items():
        
        f_output.write(dict_value["sequence_id"] + "\n")

        l_metrics = [str(dict_value["sequence_id"]), str(key), str(dict_value["sequence_length"]),
                     str(dict_value["eigenvector_centrality"]), str(dict_value["score"])]

        f_output_all.write("\t".join(l_metrics) + "\n")

        s_all_sequences.add(dict_value["sequence_id"])

        if key in s_clusters:
            f_output_unknown.write(dict_value["sequence_id"] + "\n")
            s_unknown_sequences.add(dict_value["sequence_id"])


    f_output_unknown.close()
    f_output_all.close()
    f_output.close()   

    return s_all_sequences, s_unknown_sequences


def extract_fasta_sequences(fasta, s_all_sequences, s_unknown_sequences, basename):

    f_output_all = open(f"{basename}_central_sequence.fasta", "w")
    f_output_unknown = open(f"{basename}_unknown_central_sequence.fasta", "w")

    for record in SeqIO.parse(fasta, "fasta"):
        if record.id in s_unknown_sequences:
            SeqIO.write(record, f_output_unknown, "fasta")    
        if record.id in s_all_sequences:
            SeqIO.write(record, f_output_all, "fasta")

    f_output_all.close()
    f_output_unknown.close()
    

if __name__ == '__main__':
    args = get_args()
    main(args)