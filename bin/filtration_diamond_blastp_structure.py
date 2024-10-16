#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug 21 10:33:49 2024

@author: jrousseau
"""

import pandas as pd
import sys

def main(path_dataframe):

    #dataframe = pd.read_csv("esmAtlasDBaln.tsv",
    #                        sep = "\t",
    #                        names=["qseqid", "sseqid", "pident", "ppos", "length", 
    #                               "mismatch", "gapopen", "qstart", "qend", 
    #                               "sstart", "send", "evalue", "bitscore"])
    
    dataframe = pd.read_csv(path_dataframe, sep = "\t",
                            names=["qseqid", "sseqid", "pident", "evalue"])

    
    idx = dataframe.groupby(['qseqid'])['evalue'] \
        .transform(min) == dataframe['evalue']
    
    dataframe = dataframe[idx]
    
    final_dataframe = dataframe.loc[dataframe['pident'] >= 80] 

    final_dataframe.to_csv(f"filter_{path_dataframe}", sep = "\t", index = False, 
                     header = False) 

if __name__ == '__main__':
    
    path_dataframe = sys.argv[1]
    
    main(path_dataframe)