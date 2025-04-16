#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  5 16:32:52 2025

@author: jrousseau
"""


import gzip
from argparse import ArgumentParser


def main(args):
    s_alphafold = alphafold_cluster_database(args.clusters)
    d_uniprot = uniprot_database(args.uniprot, s_alphafold)
    export_uniprot_function(d_uniprot)
    d_clusters, d_alignment = alphafold_files(args.alignment, args.clusters)
    labels_files(d_alignment, d_uniprot, d_clusters)

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
    
    parser.add_argument("-a", "--alignment", type=str,
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
    d_uniprot = dict()

    with gzip.open(uniprot, "rt") as f_gzip:
        for position, row in enumerate(f_gzip):
            print(position)
            l_row = row.strip().split("\t")
            if l_row[0] in s_alphafold:
                if l_row[3][:2] == "PF":
                    if l_row[0] not in d_uniprot.keys():
                        d_uniprot[l_row[0]] = {l_row[3]}
                    elif l_row[0] in d_uniprot.keys():
                        d_uniprot[l_row[0]].add(l_row[3])

    return d_uniprot


def export_uniprot_function(d_uniprot):
    """
    

    Parameters
    ----------
    d_uniprot : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    with open("uniprot_database.tsv", "w") as f_output:
        for key, value in d_uniprot.items():
            string_value = ";".join(value)
            f_output.write("\t".join([key, string_value]) + "\n")


def alphafold_files(alignment, clusters):
    """
    

    Parameters
    ----------
    alignment : TYPE
        DESCRIPTION.
    clusters : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    d_clusters = dict()
    d_alignment = dict()
    
    with open(alignment, "r") as f_alignment:
        for alignment in f_alignment:        
            l_alignment = alignment.rstrip("\n").split('\t')
            colA = l_alignment[0]
            colB = str(l_alignment[1].split("-")[1])
            colC = l_alignment[1]
            d_alignment[colA] = [colB, colC]
            
    with open(clusters, "r") as f_clusters:
        for row in f_clusters:
            l_row = row.strip().split("\t")
            d_clusters[l_row[0]] = l_row[1]
        
    for key, value in d_alignment.items():
        l_row = [key, value[1], value[0], d_clusters[value[0]]]
    
    
    f_alignment = open("alphafold.tsv", "w")
    
    for key, value in d_alignment.items():
        f_alignment.write('\t'.join([key, value[1], value[0], d_clusters[value[0]]]) + '\n')
    
    f_alignment.close()
    
    return d_clusters, d_alignment


def labels_files(d_alignment, d_uniprot, d_clusters):
    f_alphafold_id = open("label_alphafold_identifier.tsv", "w")
    f_alphafold_clst_id = open("label_alphafold_cluster_id.tsv", "w")
    f_alphafold_pfam_id = open("label_alphafold_pfam_id.tsv", "w")


    f_alphafold_id.write('\t'.join(["sequence_id", "label"]) + "\n")
    f_alphafold_clst_id.write('\t'.join(["sequence_id", "label"]) + "\n")
    f_alphafold_pfam_id.write('\t'.join(["sequence_id", "label"]) + "\n")

    for key in d_alignment.keys():
        alphafold_id = d_alignment[key][0]    
        f_alphafold_id.write('\t'.join([key, alphafold_id]) + '\n')
        f_alphafold_clst_id.write('\t'.join([key, d_clusters[alphafold_id]]) + '\n')
        if alphafold_id in d_uniprot.keys():
            pfam_id = ';'.join(d_uniprot[alphafold_id])
            f_alphafold_pfam_id.write('\t'.join([key, pfam_id]) + '\n')

    f_alphafold_pfam_id.close()
    f_alphafold_clst_id.close()
    f_alphafold_id.close()


if __name__ == '__main__':
    args = get_args()
    main(args)