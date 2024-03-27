#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 19:21:33 2024

@author: jeremy


se script permet de rajouter des na dans le fichier issus de mcl pour faire un tsv complet
"""

import pandas as pd
import sys


def main(path_network):
    
    """
    """
    
    network = pd.read_csv(path_network, header = None, sep = "\t")
    network['CC'] = network.index
    col = network.pop("CC")
    network.insert(0, col.name, col)
    
    network.to_csv(f"{path_network}.tsv", sep = "\t", index = None)

if __name__ == '__main__':
    
    path_network = sys.argv[1]

    main(path_network)