#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 21:39:42 2024

@author: jrousseau
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script retrieves the alignments used to reconstruct the clusters.
"""

from argparse import ArgumentParser


def main(args):
    """

    Parameters
    ----------
    args.network : STR
        Network file
    args.alignment : TSV
        BLASTp file
    args.basename : STR
        Network file name
        
    """
    d_network = read_network_file(args.network)

    alignments_selection(args.alignment, d_network, args.basename)


def get_args():
    """
    Parse arguments
    
    """
    parser = ArgumentParser(description="This script retrieves the alignments used to reconstruct the clusters")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network file", 
                        required = True)
    
    parser.add_argument("-a", "--alignment", type = str,
                        help = "BLASTp file", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network file name", 
                        required = True)

    return parser.parse_args()


def read_network_file(network):
    """
    Creating a dictionary from the Network file

    Parameters
    ----------
    network : TSV
        Network file

    Returns
    -------
    d_network : DICT
        Key: seuquence ID
        Value: cluster ID

    """
    d_network = dict()

    with open(network, 'r') as f_network:
        for row in f_network:
            l_row = row.rstrip("\n").split('\t')
            d_network[l_row[1]] = l_row[0]

    return d_network


def alignments_selection(diamond, d_network, basename):
    """
    Alignment selection by sequence pair.

    Parameters
    ----------
    diamond : TSV
        Alignment file.
    d_network : DICT
        Key: seuquence ID
        Value: cluster ID
    args.basename : STR
        Network file name

    """
    f_edge = open(f"{basename}_edges.tsv", 'w')

    with open(diamond, 'r') as f_alignment:
        for row in f_alignment:
            l_row = row.rstrip("\n").split('\t')
            if l_row[0] in d_network and l_row[4] in d_network:
                if str(d_network[l_row[0]]) == str(d_network[l_row[4]]):
                    covQ = (int(l_row[3]) - int(l_row[2]) + 1) / int(l_row[1]) * 100
                    covS = (int(l_row[7]) - int(l_row[6]) + 1) / int(l_row[5]) * 100
                    diff_cov = abs(covQ - covS)
                    l_output = [l_row[0], l_row[1], l_row[2], l_row[3],
                                l_row[4], l_row[5], l_row[6], l_row[7],
                                l_row[8], l_row[9], l_row[10], l_row[11],
                                l_row[12], str(round(diff_cov, 2)), d_network[l_row[0]]]
                    f_edge.write('\t'.join(l_output) + '\n')

    f_edge.close()

if __name__ == '__main__':
    args = get_args()
    main(args)







