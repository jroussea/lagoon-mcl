#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 11 15:17:02 2025

@author: jrousseau
"""

from argparse import ArgumentParser
import gzip
import json


def main(args):
    s_alphafold = alphafold_cluster_database(args.clusters)
    print("Extract Pfam function for each UniProt ID")
    d_uniprot = uniprot_database(args.uniprot, s_alphafold)
    print("Export informations")
    with open("uniprot_function.json", 'w') as json_file:
        json.dump(d_uniprot, json_file)

def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(
        description="Attribution d'une fonction Pfam à chaque identifiant UniProt présent dans la base de données AlphaFold Cluster")

    parser.add_argument("-c", "--clusters", type=str,
                        help="AlphaFold Cluster file (TSV) ; Disponible ici : https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz",
                        required=True)

    parser.add_argument("-u", "--uniprot", type=str,
                        help="Base de données UniProt, contient les informations lié aux identifiants UniProt ; Disponible ici : wget https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz",
                        required=True)

    return parser.parse_args()


def alphafold_cluster_database(clusters):
    """
    

    Parameters
    ----------
    clusters : TYPE
        DESCRIPTION.

    Returns
    -------
    s_alphafold : TYPE
        DESCRIPTION.

    """
    s_alphafold = set()

    with open(clusters, "r") as f_input:
        for row in f_input:
            l_row = row.rstrip("\n").split("\t")
            if l_row[0] not in s_alphafold:
                s_alphafold.add(l_row[0])

    return s_alphafold


def uniprot_database(uniprot, s_alphafold):
    """
    
    
    Parameters
    ----------
    uniprot : TYPE
        DESCRIPTION.
    s_alphafold : TYPE
        DESCRIPTION.
    
    Returns
    -------
    d_uniprot : TYPE
        DESCRIPTION.
    
    """
    d_extract = dict()
    
    with gzip.open(uniprot, "rt") as f_gzip:
        for position, row in enumerate(f_gzip):
            l_row = row.strip().split("\t")
            if l_row[0] in s_alphafold:
                if l_row[3][:2] == "PF":
                    if l_row[0] not in d_extract.keys():
                        d_extract[l_row[0]] = {l_row[3]}
                    elif l_row[0] in d_extract.keys():
                        d_extract[l_row[0]].add(l_row[3])
    
    d_uniprot = dict()

    for key, value in d_extract.items():
        d_uniprot[key] = list(value)
    
    return d_uniprot


if __name__ == '__main__':
    args = get_args()
    main(args)
    