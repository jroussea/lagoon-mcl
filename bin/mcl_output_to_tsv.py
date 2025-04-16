#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 31 09:39:42 2024

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script convert MCL output file to TSV format
"""


from argparse import ArgumentParser


def main(args):
    """

    Parameters
    ----------
    args.inflation : FLOAT
        Inflation parameter value
    args.size : INT
        Minimum cluster size
    args.network : TSV
        Network file

    """
    inflation = args.inflation.replace(".", "")
    
    f_conserved = open(f"conserved_cluster_{inflation}.txt", "w")
    f_deleted = open(f"deleted_clusters_{inflation}.txt", "w")
    f_network = open(f"network_I{inflation}.tsv", "w")
    
    f_network.write('\t'.join(["cluster_id", "sequence_id"]) + "\n")
    
    with open(args.network) as f_cluster:
        for position, row in enumerate(f_cluster):
            l_row = row.strip().split("\t")
            if len(l_row) >= int(args.size):
                f_conserved.write('\t'.join(l_row) + '\n')
                for node in l_row:
                    l_node = [str(position), str(node)]
                    f_network.write('\t'.join(l_node) + '\n')
            elif len(l_row) < int(args.size):
                f_deleted.write('\t'.join(l_row) + '\n')
        
    f_network.close()
    f_deleted.close()
    f_conserved.close()


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(description="This script convert MCL output file to TSV format")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network file", 
                        required = True)
    parser.add_argument("-i", "--inflation",  type = str,
                        help="Inflation parameter value", 
                        required = True)
    parser.add_argument("-s", "--size", type = int,
                        help="Minimum cluster size", 
                        required = True)


    return parser.parse_args()


if __name__ == '__main__':
    args = get_args()
    main(args)
