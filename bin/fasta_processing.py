#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 20 22:49:16 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script permet de préparer les séquences fasta pour le workflow LAGOON-MCL
"""


from Bio import SeqIO
from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-fi", "--fasta_input", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = False)
    
    parser.add_argument("-fo", "--fasta_output", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = False)
    
    parser.add_argument("-p", "--processing", type = str,
                        help = "cluster size min", 
                        required = False)
    
    return parser.parse_args()


def main(args):
    
    if args.processing == "header":
        
        remove_description(args.fasta_input, args.fasta_output)


def remove_description(fasta_input, fasta_output):    
    """
    Supprime la description dans les noms des séquences fasta

    Parameters
    ----------
    fasta_input : STR
        Fichier fasta.
    fasta_output : STR
        Fichier fasta renommé.

    Returns
    -------
    None.

    """
    with open(fasta_input, "r") as f_input, open(fasta_output, "w") as f_output:
        for record in SeqIO.parse(f_input, "fasta"):
            record.description = "" 
            SeqIO.write(record, f_output, "fasta")

    
if __name__ == '__main__':
    args = get_args()
    main(args)
    