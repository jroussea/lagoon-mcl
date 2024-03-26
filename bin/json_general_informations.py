#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  1 09:59:06 2024

@author: jeremy
"""

import json
import pandas as pd
import sys


def load_dataframe(path_correspondance_table):
    
    """
    
    Parameters
    ----------
    path_correspondance_table : STRING
        path to the correspondence table containing the name of each sequence
        for a single file as well as the corresponding identifiers
        
    Returns
    -------
    1 dataframe

    """
    
    correspondance_table = pd.read_table(path_correspondance_table, sep = ";",
                              names = ["sequence_header", "file_name",
                                       "darkdino_sequence_id"], 
                              header = None)

    return(correspondance_table)


def dataframe_to_dictionary(dataframe):
    
    """
    
    Parameters
    ----------
    dataframe : PANDAS DATAFRAME
        path to the correspondence table containing the name of each sequence
        for a single file as well as the corresponding identifiers
        
    Returns
    -------
    1 dictionary (converting pandas dataframe to dictionnaire)

    """
    
    df_to_dict = dataframe.to_dict(orient = "records")

    return(df_to_dict)


def save_json(list_of_dict, basename):
    
    """
    
    Parameters
    ----------
    jsonList : DICTIONARY
        dictionary corresponding to pandas dataframe
    basename : STRING
        name for output JSON file

    Returns
    -------
    JSON file

    """
    with open (f"{basename}.json", "w") as file:
        json.dump(list_of_dict, file)


def main(path_correspondance_table, basename):
    
    correspondance_table = load_dataframe(path_correspondance_table)

    df_to_dict = dataframe_to_dictionary(correspondance_table)
    
    save_json(df_to_dict, basename)
    

if __name__ == '__main__':
    path_correspondance_table = sys.argv[1]
    basename = sys.argv[2]

    main(path_correspondance_table, basename)