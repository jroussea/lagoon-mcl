#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Apr 21 12:50:01 2024

@author: jeremy
"""

import pandas as pd
import sys

def load_dataframe(path_attributes, list_columns):
    """
    chargement des différents dataframe utilisé pour construire le fichier json
    """    
    
    attributes = pd.read_csv(path_attributes, names = list_columns, sep = "\t")
    
    return(attributes)


def save_dataframe(df_label, label):

    df_label.to_csv(f"{label}.tsv", sep='\t', index=False)    


def main(path_attributes, labels, column_peptides):
    colname = labels.replace("-", ",")
        
    list_columns = colname.split(",")

    list_columns.append(column_peptides)

    attributes = load_dataframe(path_attributes, list_columns)

    columns_infos = labels.split(",")
    list_colname = []

    for position in columns_infos:
        position = position.split("-")
        list_colname.append(position)
            
    for lst in list_colname:

        if len(lst) == 2:

            lst.append(column_peptides)

            list_labels = attributes[lst[0]].unique().tolist()

            df_tmp = attributes[lst]
            
            for label in list_labels:
                
                df_label = df_tmp.loc[df_tmp[str(lst[0])] == str(label)] \
                    .drop([str(lst[0])], axis = 1) \
                        .rename(columns = {str(lst[1]):str(label)})
                            
                save_dataframe(df_label, label)
                
        elif len(lst) == 1:
            
            lst.append(column_peptides)
            
            list_labels = attributes[lst[0]].unique().tolist()

            df_label = attributes[lst]
            
            save_dataframe(df_label, lst[0])

if __name__ == '__main__':
    
    path_attributes = sys.argv[1]
    labels = sys.argv[2]
    column_peptides = sys.argv[3]
    
    main(path_attributes, labels, column_peptides)