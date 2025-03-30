#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 31 09:39:42 2024

@author: jroussea
@date: 2025-02-28
@version: 1.0
@contact: https://github.com/jroussea/lagoon-mcl/discussions
@license: MIT License
@description: Convertit le format de sortit MCL en un format plus facilement interprétable et lisible
"""


from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    
    parser = ArgumentParser(description="")
    
    parser.add_argument("-n", "--network", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    parser.add_argument("-i", "--inflation",  type = str,
                        help="Clustering inflation level (MCL parameter)", 
                        required = True)
    parser.add_argument("-s", "--size", type = int,
                        help="Minimum cluster size", 
                        required = True)


    return parser.parse_args()


def main(args):
    """
    Conversion du format de sortie MCL / Mcx Dump ou une ligne = un cluster et les noeud du cluster sont séparé par une tabultation.
    Par un fichier TSV ou :
        colonne 1 : identifiant du cluster (0, 1, 2, 3, ...)
        colonne 2 : identifiant des noeuds (1 ligne = 1 séquencee

    """
    inflation = args.inflation.replace(".", "")
    
    f_conserved = open(f"conserved_cluster_{inflation}.txt", "w")
    f_deleted = open(f"deleted_clusters_{inflation}.txt", "w")
    f_network = open(f"network_I{inflation}.tsv", "w")
    
    f_network.write('\t'.join(["cluster_id", "sequence_id"]) + "\n")
    
    with open(args.network) as f_cluster:
        
        for position, cluster in enumerate(f_cluster):
            
            l_cluster = cluster.strip().split("\t")
            
            if len(l_cluster) >= int(args.size):
    
                f_conserved.write('\t'.join(l_cluster) + '\n')
                
                for node in l_cluster:
                    l_node = [
                        str(position),
                        str(node)]
                    f_network.write('\t'.join(l_node) + '\n')
    
            elif len(l_cluster) < int(args.size):
                  
                f_deleted.write('\t'.join(l_cluster) + '\n')
        
    f_network.close()
    f_deleted.close()
    f_conserved.close()


if __name__ == '__main__':
    args = get_args()
    main(args)
