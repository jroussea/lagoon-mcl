#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 12 13:45:01 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: This script retrieves Pfam annotations linked to AlphaFold 
                sequence identifiers from the UniProt database.
"""


import json
from argparse import ArgumentParser


def main(args):
    """

    Parameters
    ----------
    args.uniprot : JSON
        JSON file excerpt from the InterPro/UniProt database containing Pfam annotations 
        linked to UniProtKB identifiers
    args.clusters : TSV
        TSV file containing sequence alignments against the AlphaFold Cluster database.
    args.alignments : TSV
        TSV file containing sequence alignments against the AlphaFold Cluster database.
    """
    d_uniprot = import_uniprot_file(args.uniprot)
    d_clusters = alphafold_cluster(args.clusters)
    d_labels = alpahfold_alignment(args.alignments)
    export_labels(d_labels, d_uniprot, d_clusters)


def get_args():
    """
    Parse arguments

    """
    parser = ArgumentParser(
        description="This script retrieves Pfam annotations linked to AlphaFold sequence identifiers from the UniProt database.")

    parser.add_argument("-c", "--clusters", type=str,
                        help="AlphaFold Cluster file; available here: https://afdb-cluster.steineggerlab.workers.dev/1-AFDBClusters-entryId_repId_taxId.tsv.gz",
                        required=True)

    parser.add_argument("-u", "--uniprot", type=str,
                        help="Excerpt from the UniProt/InterPro database; available here: wget https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz",
                        required=True)
    
    parser.add_argument("-a", "--alignments", type=str,
                        help="Sequences alignments file against AlphaFold clusters database",
                        required=True)
    
    return parser.parse_args()


def import_uniprot_file(uniprot):
    """
    Loading the JSON file

    Parameters
    ----------
    uniprot : JSON
        JSON file

    Returns
    -------
    d_uniprot : DICT
        Dictionary built from json file
            key: UniProtKB sequence identifier
            value: list of Pfam identifiers linked to sequences

    """
    with open(uniprot, 'r') as file:
        d_uniprot = json.load(file)
        
    return d_uniprot


def alphafold_cluster(clusters):
    """
    Loading the TSV file containing clusters from the AlphaFold clusters database

    Parameters
    ----------
    uniprot : TSV
        TSV file

    Returns
    -------
    d_clusters : DICT
        Dictionnaite built from TSV file
            key: Sequence identifier in the AlphaFold clusters database
            value: Identifier of clusters in the AlphaFold clusters database

    """
    d_clusters = dict()
    
    with open(clusters, "r") as f_clusters:
        for row in f_clusters:
            l_row = row.strip().split("\t")
            d_clusters[l_row[0]] = l_row[1]

    return d_clusters


def alpahfold_alignment(alignments):
    """
    Loading the TSV file containing clusters from the AlphaFold clusters database

    Parameters
    ----------
    alignments : TSV
        TSV file

    Returns
    -------
    d_labels : DICT
        Dictionnaite built from TSV file
            key: user's sequence identifier
            value: sequence identifiers in the AlphaFold clusters database (correspond to UniProtKB identifiers)

    """
    d_labels = dict()
    
    with open(alignments, "r") as f_alignments:
        for row in f_alignments:
            l_row = row.strip().split("\t")
            uniprot_id = l_row[1].split("-")[1]
            d_labels[l_row[0]] = uniprot_id

    return d_labels
    

def export_labels(d_labels, d_uniprot, d_clusters):
    """
    Loading the TSV file containing clusters from the AlphaFold clusters database

    Parameters
    ----------
    d_labels : DICT
        Dictionnaite built from TSV file
            key: user's sequence identifier
            value: sequence identifiers in the AlphaFold clusters database (correspond to UniProtKB identifiers)
    d_uniprot : DICT
        Dictionary built from json file
            key: UniProtKB sequence identifier
            value: list of Pfam identifiers linked to sequences
    d_clusters : DICT
        Dictionnaite built from TSV file
            key: Sequence identifier in the AlphaFold clusters database
            value: Identifier of clusters in the AlphaFold clusters database

    Returns
    -------
    None.

    """
    f_alphafold_id = open("alphafold_sequences.tsv", "w")
    f_alphafold_clst_id = open("alphafold_clusters.tsv", "w")
    f_alphafold_pfam_id = open("alphafold_pfam.tsv", "w")
    
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