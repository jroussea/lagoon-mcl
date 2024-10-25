#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 21 10:33:49 2024

@author: jrousseau
"""


import pandas as pd
from argparse import ArgumentParser


def get_args():
    
    """
    parser les argument
    """
    
    parser = ArgumentParser(description="")
    
    parser.add_argument("-a", "--alignment", help="Network with specific inflation", required=True)
    
    return parser.parse_args()


def main(path_dataframe):

    """
    Description:
        Filtration des alignements des séquences entre les séquences fournit par 
        l'utilisateur et celle des banques de données ESM Metagenomics Atlas
        et AlphaFold Protéin Structure Database selon le pourcentage d'identité
        
    
    input:
        clustering obtnue avec MCL (fichier dump)
    output:
        fichier contenant les cluster (même format que le fichier d'entré)
        contient uniquement les clusters avec une taille minimal 
    """    

    path_dataframe = args.alignment
    
    dataframe = pd.read_csv(path_dataframe, sep = "\t",
                            names=["qseqid", "sseqid", "pident", "evalue"])

    
    idx = dataframe.groupby(['qseqid'])['evalue'] \
        .transform(min) == dataframe['evalue']
    
    dataframe = dataframe[idx]
    
    final_dataframe = dataframe.loc[dataframe['pident'] >= 80] 

    final_dataframe.to_csv(f"filter_{path_dataframe}", sep = "\t", index = False, 
                     header = False) 

if __name__ == '__main__':
    
    args = get_args()
    
    main(args)
