#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@file    :  
@time    :  
@author  :  Jeremy Rousseau
@version :  1.0
@desc    :  
        - 

Input:
    - 
Output:
    - 
"""

import sys
import pandas as pd


def download_dataframe(path_id_tab, path_tsv_annotation, colname):
    """
    
    Parameters
    ----------
    path_id_tab : STRING
        Path to mapping table containing correspondence between sequence ID 
        and the sequence name in the original file.
    path_tsv_annotation : STRING
        Path to the file containing sequence information. For example, an
        annotation file containing PFAM annotations.
    colname : STRING
        Name of column in annotation file containing sequence names.

    Returns
    -------
    two data frames, one dataframe for the annotation table and one dataframe
    for the annotation table.

    """

    dataframe_tsv_tab = pd.read_table(path_id_tab, sep = ";", names=[colname, 
                                                                     "sequence_header", 
                                                                     "file_name", 
                                                                     "darkdino_sequence_id"], 
                                      header=None)
    dataframe_tsv_tab = dataframe_tsv_tab.drop(["sequence_header", "file_name"], axis = 1)
    
    dataframe_tsv_annotation = pd.read_table(path_tsv_annotation)
    
    return(dataframe_tsv_tab, dataframe_tsv_annotation)


def merge_dataframe(dataframe1, dataframe2, colname):
    """
    
    Parameters
    ----------
    dataframe1 : PANDAS DATAFRAME
        dataframe containing sequence identifiers and sequence names.
    dataframe2 : PANDAS DATAFRAME
        dataframe containing sequence information
    colname : STRING
        name of the column containing the names of sequences in both in 
        dataframe 1 and dataframe 2

    Returns
    -------
    A dataframe similar to the dataframe containing sequence information but 
    the column containing sequence names has been replaced by the column column
    containing sequence identifiers.
    
    """
    df_merge = pd.merge(dataframe1, dataframe2, how="left", on=colname)
    df_merge = df_merge.drop(colname, axis = 1)

    return(df_merge)


def save_dataframe(dataframe, basename):
    """

    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        dataframe containing sequence information but where sequence names have
        been replaced by the corresponding identifier
     basename : STRING
        name for output file, corresponds to the name (without extension) of
        the annotation file

    Returns
    -------
    TSV file (Tabulation Separated Values)

    """
    dataframe.to_csv(f"{basename}.sequence_id.tsv", sep = "\t", index = False) 
    

def main(id_tab, tsv_annotation, colname, basename):
    """

    Parameters
    ----------
    id_tab : PANDAS DATAFRAME
        dataframe containing sequence identifiers and sequence names.
    tsv_annotation : PANDAS DATAFRAME
        dataframe containing sequence information
    colname : STRING
        Name of column in annotation file containing sequence names.
    basename : STRING
        name for output file, corresponds to the name (without extension) of
        the annotation file
        
    Returns
    -------
    TSV file (Tabulation Separated Values)
    
    """
    
    df_tsv_id, df_tsv_annotation = download_dataframe(id_tab, tsv_annotation,
                                                      colname)
    
    df_merge = merge_dataframe(df_tsv_id, df_tsv_annotation, colname)

    save_dataframe(df_merge, basename)


if __name__ == '__main__':
    id_tab = sys.argv[1]
    tsv_annotation = sys.argv[2]
    colname = sys.argv[3]
    basename = sys.argv[4]

    main(id_tab, tsv_annotation, colname, basename)
