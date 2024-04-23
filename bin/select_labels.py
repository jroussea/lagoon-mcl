#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 26 14:01:19 2024

@author: jeremy
"""


import pandas as pd
import sys


def load_dataframe(path_sequence_annotation):
    """
    chargement des différents dataframe utilisé pour construire le fichier json
    """    
    
    sequence_annotation = pd.read_csv(path_sequence_annotation, sep = "\t")

    
    return(sequence_annotation)


def save_dataframe(dataframe, basename):
            
    dataframe.to_csv(f"{basename}.tmp", sep='\t', header = None, index = None)
    

def main(path_sequence_annotation, columns_infos, basename):
    
    columns_infos = columns_infos.replace("-", ",")
            
    list_infos = columns_infos.split(",")
        
    list_infos.append(column_peptides)
        
    sequence_annotation = load_dataframe(path_sequence_annotation)
        
    sequence_annotation_select = sequence_annotation[list_infos]
         
    save_dataframe(sequence_annotation_select, basename)



if __name__ == '__main__':
    
    path_sequence_annotation = sys.argv[1]
    columns_infos = sys.argv[2]
    column_peptides = sys.argv[3]
    basename = sys.argv[4]
    
    main(path_sequence_annotation, columns_infos, basename)