#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 12 13:45:01 2025

@author: jrousseau
"""


import json
from argparse import ArgumentParser


def main(args):
    
    d_uniprot = import_uniprot_file(args.uniprot)
    d_clusters, d_uniprot_clst = alphafold_cluster(args.clusters, d_uniprot)
    d_labels, d_alignment = alpahfold_alignment(args.alignment, d_clusters)
    export_labels(d_labels, d_uniprot, d_clusters)


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


def import_uniprot_file(uniprot):

    with open(uniprot, 'r') as file:
        d_uniprot = json.load(file)
        
    return d_uniprot


def alphafold_cluster(clusters, d_uniprot):

    d_clusters = dict()
    d_uniprot_clst = dict()
    
    with open(clusters, "r") as f_clusters:
        for line in f_clusters:
            l_line = line.strip().split("\t")
            d_clusters[l_line[0]] = l_line[1]
            
            if l_line[0] in d_uniprot.keys():
                if l_line[1] not in d_uniprot_clst.keys():
                    d_uniprot_clst[l_line[1]] = d_uniprot[l_line[0]]
                elif l_line[1] in d_uniprot_clst.keys():
                    d_uniprot_clst[l_line[1]].extend(d_uniprot[l_line[0]])
    
    return d_clusters, d_uniprot_clst


def alpahfold_alignment(alignment, d_clusters):

    d_labels = dict()
    d_alignment = dict()
    
    with open(alignment, "r") as f_alignment:
        for line in f_alignment:    
            l_line = line.strip().split("\t")
            uniprot_id = l_line[1].split("-")[1]
            d_labels[l_line[0]] = uniprot_id
            d_alignment[l_line[0]] = (l_line[1], uniprot_id, d_clusters[uniprot_id])
      
    return d_labels, d_alignment
    

def export_labels(d_labels, d_uniprot, d_clusters):
    

    f_alphafold_id = open("label_alphafold_identifier.tsv", "w")
    f_alphafold_clst_id = open("label_alphafold_cluster_id.tsv", "w")
    f_alphafold_pfam_id = open("label_alphafold_pfam_id.tsv", "w")
    
    f_alphafold_id.write('\t'.join(["sequence_id", "label"]) + "\n")
    f_alphafold_clst_id.write('\t'.join(["sequence_id", "label"]) + "\n")
    f_alphafold_pfam_id.write('\t'.join(["sequence_id", "label"]) + "\n")
    
    for key in d_labels.keys():
        alphafold_id = d_labels[key]    
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

# uniprot = "uniprot_function.json"
# clusters = "1-AFDBClusters-entryId_repId_taxId.tsv"
# alignment = "alphafold_alignment_selection.tsv"
# network = "network_I4.tsv"
# basename = "POUIC"

# d_uniprot = import_uniprot_file(uniprot)
# d_clusters, d_uniprot_clst = alphafold_cluster(clusters, d_uniprot)
# d_labels, d_alignment = alpahfold_alignment(alignment, d_clusters)
# export_labels(d_labels, d_uniprot, d_clusters)
# export_sequence_information(basename, network, d_alignment, d_uniprot, d_uniprot_clst)