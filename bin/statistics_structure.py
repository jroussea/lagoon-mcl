#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug 30 10:50:43 2024

@author: jrousseau
"""

import pandas as pd
import sys


def main(column_peptides, path_structure, path_network, inflation,basename):
    
    structure = pd.read_csv(path_structure, header = None, sep = "\t", 
                            names=["structure", column_peptides])

    network = pd.read_csv(path_network, sep = "\t")

    network_structure = pd.merge(network, structure, on = column_peptides)

        
    cluster_size = network.groupby('CC', as_index=False).count() \
        .rename(columns={column_peptides: 'CC_size'})

    structure_size = network_structure.groupby('CC', as_index=False).count() \
        .drop([column_peptides], axis=1)


    final = pd.merge(cluster_size, structure_size, on = "CC", how = "left") \
        .fillna("unknwon") \
            .rename(columns={
                "CC" : "cluster",
                "CC_size" : "cluster_size"
                })

    final.to_csv(f"{basename}_structure_I{inflation}.tsv", 
                         sep = "\t", index = None, header = True)

if __name__ == '__main__':
    
    column_peptides = sys.argv[1]
    path_structure = sys.argv[2]
    path_network = sys.argv[3]
    inflation = sys.argv[4]
    basename = sys.argv[5]


    main(column_peptides, path_structure, path_network, inflation, basename)

# column_peptides = "peptides"
# path_structure = "esm_alignment.tsv"
# path_network = "network_I1.4.tsv"
# inflation = "1.4"
# inflation = sys.argv[4]
