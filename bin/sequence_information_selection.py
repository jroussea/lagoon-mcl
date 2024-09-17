#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 17 15:07:07 2024

@author: jrousseau
"""

import pandas as pd
import sys

def main(path_attributes, peptides, columns_information):

    list_columns = [peptides]
    
    columns_information = columns_information.split(",")
    
    for i in columns_information:
        
        list_columns.append(i)
    
    attributes = pd.read_csv(path_attributes, sep = "\t")
    
    selection = attributes[list_columns]
    
    selection.to_csv(f"{path_attributes}.tsv", sep='\t', index=False, header = None)


if __name__ == '__main__':
    
    path_attributes = sys.argv[1]
    peptides = sys.argv[2]
    columns_information = sys.argv[3]
    
    main(path_attributes, peptides, columns_information)
    

#path_attributes = "Dinophyceae_organism_100-a.info"
#peptides = "protein_accession"
#columns_information = "Phylum,Class"

