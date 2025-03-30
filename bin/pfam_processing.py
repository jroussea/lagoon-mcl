#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 19 18:19:22 2025

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Ce script traite le fichier d'alignement MMseqs2 pour le rendre compatible avec le workflow LAGOON-MCL
"""


from argparse import ArgumentParser
from Bio import SeqIO


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-p", "--pfam_scan", type = str,
                        help = "pfam scan", 
                        required = True)
    
    parser.add_argument("-f", "--fasta", type = str,
                       help = "fasta file",
                       required = True)
    
    parser.add_argument("-e", "--evalue", type = float,
                        help = "evalue max", 
                        required = True)
    
    parser.add_argument("-d", "--database", type = str,
                        help = "evalue max", 
                        required = True)
    
    return parser.parse_args()

def main(args):
    """
    

    Parameters
    ----------
    args : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    pfam_m8 = open("pfam_scan_filter.m8", "w")
    pfam_format = open(f"{args.database}.tsv", "w")
    
    d_pfam = dict()
    
    #########################
    ##### Extract label #####
    #########################
    
    with open(args.pfam_scan, "r") as f_pfam:
    
        for alignment in f_pfam:
            l_alignment = alignment.rstrip("\n").split('\t')
    
            if float(l_alignment[12]) <= float(0.00001):
                
                l_m8 = [
                    l_alignment[0], str(l_alignment[1].split('.')[0]),
                    l_alignment[2], l_alignment[3], l_alignment[4], l_alignment[5],
                    l_alignment[6], l_alignment[7], l_alignment[8], l_alignment[9],
                    l_alignment[10], l_alignment[11], l_alignment[12], l_alignment[13]
                    ]
                
                pfam_m8.write('\t'.join(l_m8) + '\n') 
                
                if l_alignment[0] not in d_pfam:
                    
                    d_pfam[l_alignment[0]] = {l_alignment[1].split('.')[0]}
                
                elif l_alignment[0] in d_pfam:
                    
                    d_pfam[l_alignment[0]].add(l_alignment[1].split('.')[0])

    #############################
    ##### Write output file #####
    #############################

    for record in SeqIO.parse(args.fasta, "fasta"):
        
        if record.id not in d_pfam.keys():
            l_label = [str(record.id), "NA", args.database]
         
        elif record.id in d_pfam.keys():
            l_label = [str(record.id), str(";".join(list(d_pfam[record.id]))), args.database]
        
        pfam_format.write('\t'.join(l_label) + '\n')


                    
    # for key, value in d_pfam.items():
    
    #     l_label = [str(key), str(";".join(list(value))), args.database]
        
    #     pfam_format.write('\t'.join(l_label) + '\n')
        
    pfam_format.close()
    pfam_m8.close()


if __name__ == '__main__':
    args = get_args()
    main(args)