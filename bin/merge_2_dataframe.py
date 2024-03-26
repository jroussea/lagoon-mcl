#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@file    :  
@time    :  
@author  :  Jeremy Rousseau
@version :  1.0
@desc    :  
This module allows you to rename fasta files:
        - 

Input:
    - 
Output:
    - 
"""

import sys
import pandas as pd

def download_dataframe(path_dataframe, cor_table):
    
    """
    
    Parameters
    ----------
    path_dataframe : STRING
        path to file containing list of all sequences in a file
    cor_table : STRING
        path to the mapping table containing the identifiers and names of all
        file sequences
        
    Returns
    -------
    two pandas dataframe

    """
    
    dataframe_proteome = pd.read_table(proteome_name, names=["sequence_name"], 
                                       header=None)
    dataframe_cor_table = pd.read_table(cor_table, names=["sequence_name", 
                                                          "sequence_id", 
                                                          "file_name"], 
                                        header=None)
    
    return(dataframe_proteome, dataframe_cor_table)


def add_column(dataframe, option = "NA"):
    
    """
    
    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        dataframe containing a list of all sequences for a single file
    option : STRING
        
    Returns
    -------
    pandas dataframe containing the list of all sequences for a single file.
    this dataframe also contains a column with the file name
    
    """

    dataframe.insert(loc = 1, column = 'file_name', value = option)

    return(dataframe)


def merge_dataframe(df_prot_name, df_cor_table):
    
    """
    
    Parameters
    ----------
    df_prot_name : PANDAS DATAFRAME
        dataframe containing a list of all sequences for a single file
    df_cor_table : PANDAS DATAFRAME
        Correspondence table containing the list of all sequences present in all 
        files. In addition, this correspondence table contains the identifier 
        of each sequence
        
        
    Returns
    -------
    dataframe. creation of a correspondence table for each file entered in the 
    workflow. The dataframe contains the names of the sequences present in a 
    single fasta file, with a column containing the identifier corresponding to 
    the sequence and the name of the file in which the sequence can be found.
    
    """

    df_merge = pd.merge(df_prot_name, df_cor_table, on = 'sequence_name')
        
    return(df_merge)


def save_dataframe(df_merge, proteome_basename):
    
    """
    
    Parameters
    ----------
    df_merge : PANDAS DATAFRAME
        correspondance table for a single fasta file containing sequence names 
        and identifiers
    proteome_basename : STRING
        TSV file name

    Returns
    -------
    TSV file (Tabulation Separated Values)

    """
    
    df_merge.drop(df_merge.columns[3], axis=1, inplace=True)
    df_merge.to_csv(f"{proteome_basename}.id_tsv", sep = ";", index = False,
                    header = False)


def main(proteome_basename, proteome_name, cor_table):

    """
    
    Parameters
    ----------
    proteome_basename : STRING
        TSV file name
    proteome_name : STRING
        path to file containing list of all sequences in a file
    cor_table : STRING
        Path to correspondence table containing the names of all sequences present in
        all fasta files.
        there's also the identifier corresponding to each sequence

    Returns
    -------
    TSV file (Tabulation Separated Values)

    """
    
    df_prot_name, df_cor_table = download_dataframe(proteome_name, cor_table)
    
    df_prot_name = add_column(df_prot_name, option = proteome_basename)

    df_prot_name = merge_dataframe(df_prot_name, df_cor_table)

    save_dataframe(df_prot_name, proteome_basename)


if __name__ == '__main__':
    proteome_basename = sys.argv[1]
    proteome_name = sys.argv[2]
    cor_table = sys.argv[3]
    
    main(proteome_basename, proteome_name, cor_table)
