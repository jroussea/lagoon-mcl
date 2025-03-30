#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  5 18:37:17 2025

@author: jrousseau
"""


from argparse import ArgumentParser
import json


def main(args):
    
    d_uniprot = import_uniprot_file(args.uniprot)
    d_uniprot_clst, d_clusters = alphafold_clusters(args.clusters, d_uniprot)
    d_alignment = alphafold_alignment(args.alignment, d_clusters)
    export_sequence_information(args.network, args.basename, d_alignment, d_uniprot, d_uniprot_clst)


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
    
    parser.add_argument("-n", "--network", type=str,
                        help="Base de données UniProt, contient les informations lié aux identifiants UniProt ; Disponible ici : wget https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz",
                        required=True)
    
    parser.add_argument("-b", "--basename", type=str,
                        help="Base de données UniProt, contient les informations lié aux identifiants UniProt ; Disponible ici : wget https://ftp.ebi.ac.uk/pub/databases/interpro/current_release/protein2ipr.dat.gz",
                        required=True)

    return parser.parse_args()

    
def import_uniprot_file(uniprot):

    with open(uniprot, 'r') as file:
        d_uniprot = json.load(file)
        
    return d_uniprot


def alphafold_clusters(clusters, d_uniprot):
    """
    

    Parameters
    ----------
    clusters : TYPE
        DESCRIPTION.
    d_uniprot : TYPE
        DESCRIPTION.

    Returns
    -------
    d_uniprot_clst : TYPE
        DESCRIPTION.

    """
    d_uniprot_clst = dict()
    d_clusters = dict()
    
    with open(clusters, "r") as f_clusters:
        for row in f_clusters:
            l_row = row.rstrip("\n").split("\t")
            d_clusters[l_row[0]] = l_row[1]
            if l_row[0] in d_uniprot.keys():
                if l_row[1] not in d_uniprot_clst.keys():
                    d_uniprot_clst[l_row[1]] = d_uniprot[l_row[0]]
                elif l_row[1] in d_uniprot_clst.keys():
                    d_uniprot_clst[l_row[1]].extend(d_uniprot[l_row[0]])
    
    return d_uniprot_clst, d_clusters


def alphafold_alignment(alignment, d_clusters):
    """
    

    Parameters
    ----------
    alignment : TYPE
        DESCRIPTION.

    Returns
    -------
    d_alignment : TYPE
        DESCRIPTION.

    """
    d_alignment = dict()
    
    with open(alignment, "r") as f_alignment:
        for line in f_alignment:
            l_line = line.strip().split("\t")
            uniprot_id = l_line[1].split("-")[1]
            d_alignment[l_line[0]] = (l_line[1], uniprot_id, d_clusters[uniprot_id])
            
    return d_alignment


def export_sequence_information(network, basename, d_alignment, d_uniprot, d_uniprot_clst):
    """
    

    Parameters
    ----------
    network : TYPE
        DESCRIPTION.
    basename : TYPE
        DESCRIPTION.
    d_alignment : TYPE
        DESCRIPTION.
    d_uniprot : TYPE
        DESCRIPTION.
    d_uniprot_clst : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """

    
    f_network_structure = open(f"{basename}_alphafold_cluster.tsv", "w")
    
    f_network_structure.write("\t".join(["sequence_id", "cluster_id", "alphafold_id", "alphafold_clst", "pfam_id", "pfam_id_clst", "all_pfam_id_clst"]) + "\n")
    
    with open(network, "r") as f_network:
    
        header = f_network.readline().strip()
        columns = header.split("\t")
    
        for position, node in enumerate(f_network):
            l_node = node.rstrip("\n").split('\t')
    
            if l_node[1] in d_alignment.keys():
                alphafold_sequence = d_alignment[l_node[1]][1]
                alphafold_cluster =  d_alignment[l_node[1]][2]
                
                # if l_node[0] not in d_alphafold_sequence.keys():
                    # d_alphafold_sequence[l_node[0]] = [alphafold_sequence]
                # else:
                    # d_alphafold_sequence[l_node[0]].append(alphafold_sequence)
                
                # if l_node[0] not in d_alphafold_cluster.keys():
                    # d_alphafold_cluster[l_node[0]] = [alphafold_cluster]
                # else:
                    # d_alphafold_cluster[l_node[0]].append(alphafold_cluster)
                
                if alphafold_sequence in d_uniprot.keys():
                    afold_pfam = str(';'.join(d_uniprot[alphafold_sequence]))
                else:  
                    afold_pfam = "NA"
    
                if alphafold_cluster in d_uniprot.keys():
                    afold_pfam_clst = str(';'.join(d_uniprot[alphafold_cluster]))
                else:
                    afold_pfam_clst = "NA"
    
                if alphafold_cluster in d_uniprot_clst.keys():
                    afold_all_pfam_clst = str(';'.join(d_uniprot_clst[alphafold_cluster]))
                else:
                    afold_all_pfam_clst = "NA"
    
                l_node_structure = [str(l_node[1]), str(l_node[0]),
                                    alphafold_sequence, alphafold_cluster,
                                    afold_pfam, afold_pfam_clst, afold_all_pfam_clst]
    
            else:
                l_node_structure = [str(l_node[1]), str(l_node[0]), 
                                    "NA", "NA", "NA", "NA"]
    
            f_network_structure.write('\t'.join(l_node_structure) + '\n')
    
    f_network_structure.close()
    
    
if __name__ == '__main__':
    args = get_args()
    main(args)