#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 21 12:50:01 2024

@author: jeremy
"""

import pandas as pd
import sys

def load_dataframe(path_attributes):
    """
    chargement des différents dataframe utilisé pour construire le fichier json
    """    
    
    attributes = pd.read_csv(path_attributes, sep = "\t")
    
    return(attributes)


def save_dataframe(df_label, label, column_peptides):

    df_label['database'] = label
    
    df_label_rename = df_label.rename(columns={label: 'database_accession'})
    
    df_label_rename.to_csv(f"{label}.tsv", sep='\t', index=False, header = True)


def main(path_attributes, labels, column_peptides):
    list_columns = labels.split(",")

    list_columns.append(column_peptides)

    attributes = load_dataframe(path_attributes)

    list_colname = labels.split(",")
            
    for lst in list_colname:    

        df_label = attributes[[lst, column_peptides]]
        
        save_dataframe(df_label, lst, column_peptides)

if __name__ == '__main__':
    
    path_attributes = sys.argv[1]
    labels = sys.argv[2]
    column_peptides = sys.argv[3]
    
    main(path_attributes, labels, column_peptides)


#path_attributes = "classification.tsv"
#labels = "class,architecture,topology,superfamily"
#column_peptides = "protein_accession"