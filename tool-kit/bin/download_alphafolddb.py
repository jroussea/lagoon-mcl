#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 15:36:02 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script permet d'obtenir les séquences FASTA des structure présente dans AlphaFold Cluster database
"""


from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="Ce programme permet de récupérer les ID \
                            des séquences/structure présente dans AlphaFold Cluster \
                            et des les sauvegarder dans un fochier .txt")
    
    parser.add_argument("-a", "--alphafold", type = str,
                        help = "Liste des séquences et clsuter présent dans AlphaFold Cluster", 
                        required = True)
    
    
    return parser.parse_args()


def alphafold_foldseek(alphafold_sequences):
    """
    Écriture d'une fichier TXT qui liste les identifiants des séquences en rajoutant les 
    termes : AFDB:AF-[...]-F1 présent dans les identifants des séquences AlphaFold.

    Parameters
    ----------
    alphafold_sequences : STR
        Fichier TSV contenant :
            Colonne 1 : séquence présente dans AlphaFold Cluster.
            Colonne 2 : identifiant des cluster ALphaFold Cluster.
            Colonne 3 : identifiant taxonomique.

    Returns
    -------
    None.

    """
    file = open("sequences_id_alphafold_cluster_foldseek.txt", "w")

    with open(alphafold_sequences, "r") as f_alphafold_cluster:
        
        for node in f_alphafold_cluster:
            l_node = node.rstrip("\n").split('\t')
            
            file.write(f"AFDB:AF-{l_node[0]}-F1" + "\n")

    file.close()


def main(args):
    """
    AlphaFold Cluster database :
        Site web : https://cluster.foldseek.com/
        Paper : https://doi.org/10.1038/s41586-023-06510-w
    
    AlphaFold Protein Structure Database : 
        Sité Web : https://alphafold.com/
        Paper : https://doi.org/10.1093/nar/gkad1011

    """
    alphafold_foldseek(args.alphafold)


if __name__ == '__main__':
    args = get_args()
    main(args)





