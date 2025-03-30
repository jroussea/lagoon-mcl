#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 21 18:29:39 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script prépare les fichier Label pour le workflow LAGOON-MCL
"""


from Bio import SeqIO
from argparse import ArgumentParser


def main(args):

    d_label = dictionary_label(args.label)
    
    f_label = open(f"label_{args.database}.tsv", "w")

    #f_label.write('\t'.join(["sequence_id", f"{args.database}"])+ '\n')

    for record in SeqIO.parse(args.fasta, "fasta"): 
        """
        Objectif : rajouter les séquences sans label dans le fichier de label
        si la séquence n'est pas présent dans le dictionaire d_label alors le label
        sera NA
        """
        if record.id not in d_label.keys():
            f_label.write('\t'.join([record.id,"NA", args.database]) + "\n")
        
        elif record.id in d_label.keys():
            f_label.write('\t'.join([record.id, d_label[record.id], args.database]) + '\n')

    f_label.close()


def get_args():
    """
    Parse arguments
    
    """
    parser = ArgumentParser(description="Préparation des fichier label ")
    
    parser.add_argument("-l", "--label", type = str,
                        help = "Fichier contenant les label (par exemple identifant Gene3D) pour chaque séquences qui en possède. \
                            si plusieurs label pour une même séquence, alors il faut qu'elle soit séparé par \";\"", 
                        required = True)
    
    parser.add_argument("-f", "--fasta", type = str,
                        help = "Fichier Fasta qui contient toutes les séquences qui vont être analysé par LAGOON-MCL", 
                        required = True)
    
    parser.add_argument("-d", "--database", type = str,
                        help = "Nom de la base de données dont son issu les label (par exemple Gene4D, FunFam, Pfam)", 
                        required = True)

    return parser.parse_args()


def dictionary_label(label):
    """
    

    Parameters
    ----------
    label : STR
        Ficheir TSV contenant les label.
            colonne 1 : identifiant des séquences
            colonne 2 : label, si plusieurs label pour une même séquence, alors
                ils doivent être mis sur la même ligne séparé par un ;

    Returns
    -------
    d_label : DICT
        Clé : idenfiant des séquence.
        Valeur : identifiant des label (string), séparé par le ; s'il y en a plusieurs
        
    """
    d_label = dict()
    
    with open(label, "r") as f_label:
        
        for position, sequence in enumerate(f_label):
            if position != 0:
                l_sequence = sequence.rstrip("\n").split("\t")
            
                d_label[l_sequence[0]] = l_sequence[1]
            
    return d_label


if __name__ == '__main__':
    args = get_args()
    main(args)
