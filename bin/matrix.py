#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 13 18:56:59 2024

@author: jrousseau
"""

import pandas as pd
from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    
    parser = ArgumentParser(description="")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    parser.add_argument("-a", "--annotation", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    parser.add_argument("-i", "--inflation", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    return parser.parse_args()


def main(args):
    
    dict_matrix= {}
    
    with open(args.network) as annotation:
        for position, annotation in enumerate(annotation):
            annotation = annotation.strip()
            list_node = annotation.split('\t')
            
            
            if list_node[1] in dict_matrix:
                dict_matrix[list_node[1]][int(list_node[0])] = int(list_node[2])
                
            else:
                dict_matrix[list_node[1]] = {int(list_node[0]): int(list_node[2])}
    
    matrix = pd.DataFrame.from_dict(dict_matrix)
    matrix = matrix.reset_index()
    matrix = matrix.rename(columns = {'index' : 'cluster_id'}).fillna(0).astype(int)
    
    matrix.to_csv(f"abundance_matrix_{args.annotation}_{args.inflation}", 
                  sep = "\t", index = None, header = True)
    

if __name__ == '__main__':
    args = get_args()
    main(args)
