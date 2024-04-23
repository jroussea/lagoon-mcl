#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 22 15:02:43 2024

@author: jeremy

préparation du ficheir d'alignement pour mcl

objectif supprimer les alignement des séquences contre elle même
"""

import sys
import pandas as pd


def download_dataframe(dataframe):
    """
    
    Parameters
    ----------
    dataframe : STRING
        path to dataframe containing diamond results

    Returns
    -------
    pandas dataframe

    """
    
    df_dataframe = pd.read_table(dataframe, header=None)
    df_dataframe.columns = \
        [ i for i in range(1, len(df_dataframe.columns)+1, 1) ]
    
    return(df_dataframe)

def save_dataframe(dataframe):
    """
    
    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        pandas datafame containing diamond results
        
    Returns
    -------
    TSV file (Tabulation Separated Values)

    """
    
    dataframe.to_csv("diamond_ssn.tsv", sep = "\t", index = False, 
                     header = False) 


def main(diamond_alignment, query, subject, evalue):
    """
    
    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        pandas datafame containing diamond results
    dataframe_name : STRING
        TSV file name
        
    Returns
    -------
    TSV file (Tabulation Separated Values)

    """

    df_diamond_alignment = download_dataframe(diamond_alignment)
    
    index = df_diamond_alignment[(df_diamond_alignment[query] == \
                                  df_diamond_alignment[subject])].index
    
    df_diamond_alignment.drop(index, inplace = True)
    
    df_diamond_alignment = df_diamond_alignment[[query, subject, evalue]]
    
    save_dataframe(df_diamond_alignment)


if __name__ == '__main__':
    diamond_alignment = sys.argv[1]
    query = int(sys.argv[2])
    subject = int(sys.argv[3])
    evalue = int(sys.argv[4])
    
    main(diamond_alignment, query, subject, evalue)
