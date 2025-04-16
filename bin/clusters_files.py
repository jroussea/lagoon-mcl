#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 10 15:18:40 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script generates files (metrics) specific to the clusters present in the networks.
"""


from argparse import ArgumentParser
import json
import os


def main(args):
    """

    Parameters
    ----------
    args.diameter: JSON
        JSON file containing the diameter of each cluster
    args.homogeneity_score: TSV
        TSV files of homogeneity scores for each cluster
    args.basename: STR
        Network name: "network_I[inflation]"

    """
    with open(args.diameter, 'r') as f_json:
        d_diameter = json.load(f_json)

    with open(args.homogeneity_score, "r") as f_input:
        with open("temporary", "w") as f_tmp:
            for position, row in enumerate(f_input):
                l_row = row.strip().split("\t")
                first_part = l_row[:2]
                second_part = l_row[2:]
                if position == 0:
                    new_row = first_part + ["diameter"] + second_part
                else:
                    new_row = first_part + [str(d_diameter[first_part[0]])] + second_part
                
                f_tmp.write('\t'.join(new_row) + '\n')
                
    os.replace("temporary", f"{args.basename}_clusters_metrics.tsv")


def get_args():
    """

    Parse arguments

    """
    parser = ArgumentParser(description="This script generates files (metrics) specific to the clusters present in the networks.")
    
    parser.add_argument("-d", "--diameter", type = str,
                        help = "JSON file containing the diameter of each cluster", 
                        required = True)
    
    parser.add_argument("-hs", "--homogeneity_score", type = str,
                        help = "TSV file containing homogeneity scores for each cluster", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network name", 
                        required = True)
    
    return parser.parse_args()


if __name__ == '__main__':
    args = get_args()
    main(args)
