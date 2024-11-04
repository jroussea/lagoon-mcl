#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 21 12:50:01 2024

@author: Jérémy Rousseau
"""


import pandas as pd
from argparse import ArgumentParser


def get_args():    
    """
    Parse arguments
    """
    
    parser = ArgumentParser(description="")
    
    parser.add_argument("-a", "--annotation", type = str, 
                        help = "File containing the different CATH \
                            classification levels", 
                        required = True)
    parser.add_argument("-l", "--labels", type = str, 
                        help = "The different CATH levels (Class, Architecture, \
                            Topology, Superfamily)", 
                        required = True)
    
    return parser.parse_args()


def main(args):
    
    """
    DESCRIPTION
    -----------
        Generate a file for each level of the CATH classification 
        (Class, Architecture, Topology, Superfamily) classification.
    
    INPUT
    -----
        TSV file with 5 columns
            - column 1: protein accession
            - column 2: ID for the “Class” level
            - column 3: ID for the "Architecture" level
            - column 4: ID for the "Topology" level
            - column 5: ID for the "Superfamily" level
    OUTPUT
    ------
        4 TSV files for each classification level (with 3 columns)
            - colum, 1 : protein accession
            - column 2 : CATH classification ID
            - column 3 : classification level (Class, Architecture, Topology \
                                               or Superfamily)
    """
    
    annotation = pd.read_csv(args.annotation, sep = "\t")
        
    all_labels = args.labels.split(",")
    
    print(all_labels)
    
    for labels in all_labels:    
        df_label = annotation[["protein_accession", labels]]
        
        df_label['database'] = f"gene3d_{labels}"
        df_label_rename = df_label \
            .rename(columns = {labels: 'database_accession'})
        
        ##############################################################
        ###### Save each classification level in separate files ######
        ##############################################################
        
        df_label_rename.to_csv(f"gene3d_{labels}.tsv", sep='\t', index=False, 
                               header = True)
        
    
        
if __name__ == '__main__':
    args = get_args()
    main(args)