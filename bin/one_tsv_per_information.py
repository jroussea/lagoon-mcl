#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep  2 17:11:03 2024

@author: jrousseau
"""

import pandas as pd
import sys


def main(path_attributes, peptides, columns_information):

    list_columns = [peptides]
    
    columns_information = columns_information.split(",")
    
    for i in columns_information:
        
        list_columns.append(i)
    
    attributes = pd.read_csv(path_attributes, names = list_columns, sep = "\t")
    
    for column in columns_information:
        
        print(column)
        
        df_label = attributes[[peptides, column]]
        
        df_label.to_csv(f"{column}.tsv", sep='\t', index=False)
        

if __name__ == '__main__':
    
    path_attributes = sys.argv[1]
    peptides = sys.argv[2]
    columns_information = sys.argv[3]
    
    main(path_attributes, peptides, columns_information)
    

#path_attributes = "basename.info"

#peptides = "peptides"
#columns_information = "A,B,C"

