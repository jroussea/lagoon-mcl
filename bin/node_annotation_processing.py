#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar  4 15:31:10 2025

@author: jrousseau
"""


from argparse import ArgumentParser
from Bio import SeqIO
import os

def main(args):
    
    d_network = dict_network(args.network)
    s_labels = set_labels(args.labels)
    d_length = sequence_length(args.fasta)
    output = output_file(args.basename, d_network, d_length)
    
    for database in s_labels:
        d_labels = dict_labels(args.labels, d_network, database)
        with open(output, "r") as f_output:
            with open("temporary", "w") as f_tmp:
    
                
                for position, line in enumerate(f_output):
                    l_line = line.strip().split("\t")
                    sequence_id = l_line[0]
                        
                    if position == 0:
                        modified_line = l_line + [f"{database}"]
                        f_tmp.write('\t'.join(modified_line) + "\n")
    
                    else:
                        if sequence_id in d_labels.keys():
                            label = ";".join([d_labels[sequence_id]])
                            modified_line = l_line + [f"{label}"]
                            f_tmp.write('\t'.join(modified_line) + '\n')
    
        os.replace("temporary", output)

def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-l", "--labels", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "cluster size min", 
                        required = True)
    
    parser.add_argument("-f", "--fasta", type = str,
                        help = "cluster size min", 
                        required = True)
    
    return parser.parse_args()


def dict_network(network):

    d_network = dict()
    
    with open(network, "r") as f_network:
        
        header = f_network.readline().strip()
        columns = header.split("\t")
    
        for row in f_network:
            l_row = row.strip().split("\t")
            
            d_network[l_row[1]] = l_row[0]
    
    return d_network


def set_labels(labels):
    
    s_labels = set()
    
    with open(labels, "r") as f_labels:
        for line in f_labels:
            l_line = line.strip().split("\t")
            if l_line[2] not in s_labels:
                s_labels.add(l_line[2])
    
    return s_labels
    

def dict_labels(labels, d_network, database):

    d_labels = dict()
    
    with open(labels, "r") as f_labels:
        
        for line in f_labels:
            
            l_line = line.strip().split("\t")
            
            # if l_row[2] not in s_database:
            #     s_database.add(l_row[2])
            
            if l_line[2] == database:
                d_labels[l_line[0]] = l_line[1]
                
            
            # if l_line[2] not in d_labels.keys():
            #     d_labels[l_line[2]] = dict()
            
            # elif l_line[0] in d_network.keys():
            #     d_labels[l_line[2]][l_line[0]] = l_line[1]
    
    return d_labels


def output_file(basename, d_network, d_length):
    
    output = f"node_annotation_{basename}.tsv"
    
    f_output = open(f"node_annotation_{basename}.tsv", "w")
    
    f_output.write('\t'.join(["sequence_id", "cluster_id", "sequence_length"]) + '\n')
    
    for sequence_id, cluster_id in d_network.items():
        
        f_output.write('\t'.join([sequence_id, cluster_id, str(d_length[sequence_id])]) + '\n')
    
    f_output.close()
    
    return output


def sequence_length(fasta):

    d_length = dict()
    
    with open(fasta, "r") as handle:
        records = SeqIO.parse(handle, "fasta")
        
        for record in records:
            
            d_length[record.id] = len(record.seq)
        d_length[record.id]
    
    return d_length


if __name__ == '__main__':
    args = get_args()
    main(args)


# d_network = dict_network("network_I14.tsv")
# s_labels = set_labels("labels.tsv")
# d_length = sequence_length("sequences_rename.fasta")
# output = output_file("POUIC", d_network, d_length)

# for database in s_labels:
#     d_labels = dict_labels("labels.tsv", d_network, database)
#     with open(output, "r") as f_output:
#         with open("temporary", "w") as f_tmp:

            
#             for position, line in enumerate(f_output):
#                 l_line = line.strip().split("\t")
#                 sequence_id = l_line[0]
                    
#                 if position == 0:
#                     modified_line = l_line + [f"{database}"]
#                     f_tmp.write('\t'.join(modified_line) + "\n")

#                 else:
#                     if sequence_id in d_labels.keys():
#                         label = ";".join([d_labels[sequence_id]])
#                         modified_line = l_line + [f"{label}"]
#                         f_tmp.write('\t'.join(modified_line) + '\t')
    
#     os.replace("temporary", output)
