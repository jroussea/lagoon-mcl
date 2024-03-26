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
    
    dl_dataframe = pd.read_table(dataframe,
                                 names=["qsedid", "sseqid", "pident", "ppos", 
                                        "lenght", "mismatch", "gapopen", 
                                        "qstart", "qend", "sstart", "send",
                                        "evalue", "bitscore"],
                                 header=None)
    
    return(dl_dataframe)


def index_alignement(dataframe):
    """
    
    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        pandas datafame containing diamond results

    Returns
    -------
    (list) index of rows where column qsedid is equal to column sseqid

    """
    
    index_al = dataframe[(dataframe['qsedid'] == dataframe['sseqid'])].index
    
    return(index_al)


def drop_alignment(dataframe, index):
    """
    
    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        pandas datafame containing diamond results
    index : LIST
        list containing row indexes where column qsedid is equal to column sseqid
        
    Returns
    -------
    dataframe with deleted rows (column qsedid equals column sseqid)

    """
    
    dataframe.drop(index, inplace = True)

    return(dataframe)


def save_dataframe(dataframe, dataframe_name):
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
    
    dataframe.to_csv(f"{dataframe_name}.itself_tsv", sep = "\t", index = False, 
                     header = False) 


def main(diamond_alignment, diamond_al_name):
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
    
    index_al = index_alignement(df_diamond_alignment)
    
    df_diamond_alignment = drop_alignment(df_diamond_alignment, index_al)
    print(df_diamond_alignment)
    
    save_dataframe(df_diamond_alignment, diamond_al_name)


if __name__ == '__main__':
    diamond_alignment = sys.argv[1]
    diamond_al_name = sys.argv[2]
    
    main(diamond_alignment, diamond_al_name)








