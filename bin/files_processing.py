#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 20 22:49:16 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script is used to prepare fasta sequences for LAGOON-MCL
"""


from Bio import SeqIO
from argparse import ArgumentParser
import os


def main(args):
    """

    Parameters
    ----------
    args.fasta: FASTA
        Input fasta file
    args.fasta_output: FASTA
        Output fasta file
    args.labels: TSV
        Annotations files
    args.network: TSV
        Network files
    args.basename: STR
        Network name
    args.database: STR
        Annotation name

    """
    if args.processing == "fasta":    
        remove_description(args.fasta, args.fasta_output)

    elif args.processing == "labels":
        write_labels_file(args.labels, args.database, args.fasta)

    elif args.processing == "nodes":
        d_network, d_hash = dict_network(args.network)
        d_length = sequence_length(args.fasta)
        output = output_file(args.basename, d_network, d_length)
        d_labels = dict_labels_nodes_processing(args.labels, d_hash)
        write_temporary_file(output, d_labels, d_hash)

    elif args.processing == "pfam":
        pfam_processing(args.database, args.pfam_scan, args.fasta)

def get_args():
    """

    Parse arguments
    
    """
    parser = ArgumentParser(description="This script is used to prepare fasta sequences for LAGOON-MCL")
    
    parser.add_argument("-f", "--fasta", type = str,
                        help = "Input fasta file", 
                        required = False)
    
    parser.add_argument("-fo", "--fasta_output", type = str,
                        help = "Output fasta file", 
                        required = False)

    parser.add_argument("-l", "--labels", type = str,
                        help = "Annotation files", 
                        required = False)

    parser.add_argument("-d", "--database", type = str,
                        help = "Annotation name", 
                        required = False)

    parser.add_argument("-n", "--network", type = str,
                        help = "Network file", 
                        required = False)

    parser.add_argument("-b", "--basename", type = str,
                        help = "Network name", 
                        required = False)

    parser.add_argument("-ps", "--pfam_scan", type = str,
                        help = "pfam scan", 
                        required = False)

    parser.add_argument("-p", "--processing", type = str,
                        help = "Processing type", 
                        required = True)

    return parser.parse_args()


def remove_description(fasta_input, fasta_output):    
    """
    Supprime la description dans les noms des séquences fasta

    Parameters
    ----------
    fasta_input : STR
        Fichier fasta.
    fasta_output : STR
        Fichier fasta renommé.

    Returns
    -------
    None.

    """
    with open(fasta_input, "r") as f_input, open(fasta_output, "w") as f_output:
        for record in SeqIO.parse(f_input, "fasta"):
            record.description = "" 
            SeqIO.write(record, f_output, "fasta")


def write_labels_file(labels, database, fasta):
    """

    Parameters
    ----------
    labels: TSV
        User-supplied annotation file

    database: TSV
        Type of annotation present in “labels” file (e.g. Pfam)

    fasta: FASTA
        File with protein sequences

    """
    d_label = dict_labels_annotation_processing(labels)
    
    f_label = open(f"labels_{database}.tsv", "w")

    for record in SeqIO.parse(fasta, "fasta"): 
        """
        Goal 
        --------
        Add unannotated sequences to the annotation file
        The annotation assigned to these sequences is “NA”.
        """
        if record.id not in d_label.keys():
            f_label.write('\t'.join([record.id,"NA", database]) + "\n")

        elif record.id in d_label.keys():
            f_label.write('\t'.join([record.id, d_label[record.id], database]) + '\n')

    f_label.close()


def dict_labels_annotation_processing(labels):
    """
    Create a dictionary from the labels file

    Parameters
    ----------
    label : STR
        TSV file with labels.
            column 1: sequence ID
            column 2: label, if several labels for the same sequence, 
                        then they must be put on the same line separated by a ”;

    Returns
    -------
    d_label : DICT
        Key: sequence ID.
        Value: label identifier (string), separated by “;” if more than one.

    """
    d_label = dict()
    
    with open(labels, "r") as f_label:
        
        for position, row in enumerate(f_label):
            if position != 0:
                l_row = row.rstrip("\n").split("\t")
            
                d_label[l_row[0]] = l_row[1]
            
    return d_label


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


def pfam_processing(database, pfam_scan, fasta):
    """
    Préparation du fichier d'annotation Pfam

    Parameters
    ----------
    database: STR
        Type of annotation present in “labels” file (e.g. Pfam)
    pfam_scan: TSV
        File name with alignments against Pfam database
    fasta: FASTA:
        Fasta file name
        
    Returns
    -------
    None.

    """
    pfam_m8 = open("pfam_scan_filter.m8", "w")
    pfam_format = open(f"{database}.tsv", "w")
    
    d_pfam = dict()
    
    #########################
    ##### Extract label #####
    #########################

    with open(pfam_scan, "r") as f_pfam:
    
        for row in f_pfam:
            l_row = row.rstrip("\n").split('\t')
    
            if float(l_row[12]) <= float(0.00001):
                
                l_m8 = [
                    l_row[0], str(l_row[1].split('.')[0]),
                    l_row[2], l_row[3], l_row[4], l_row[5],
                    l_row[6], l_row[7], l_row[8], l_row[9],
                    l_row[10], l_row[11], l_row[12], l_row[13]
                    ]
                
                pfam_m8.write('\t'.join(l_m8) + '\n') 
                
                if l_row[0] not in d_pfam:
                    
                    d_pfam[l_row[0]] = {l_row[1].split('.')[0]}
                
                elif l_row[0] in d_pfam:
                    
                    d_pfam[l_row[0]].add(l_row[1].split('.')[0])

    #############################
    ##### Write output file #####
    #############################

    for record in SeqIO.parse(fasta, "fasta"):
        
        if record.id not in d_pfam.keys():
            l_label = [str(record.id), "NA", database]

        elif record.id in d_pfam.keys():
            l_label = [str(record.id), str(";".join(list(d_pfam[record.id]))), database]
        
        pfam_format.write('\t'.join(l_label) + '\n')

    pfam_format.close()
    pfam_m8.close()

if __name__ == '__main__':
    args = get_args()
    main(args)
    