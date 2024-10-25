#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 18 19:15:54 2024

@author: Jérémy Rousseau
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
    parser.add_argument("-i", "--inflation",  type = float,
                        help="Clustering inflation level (MCL parameter)", 
                        required = True)
    parser.add_argument("-m", "--min", type = int,
                        help="Minimum cluster size", 
                        required = True)

    return parser.parse_args()


def main(args):
    """
    DESCRIPTION
    -----------
        Cluster selection with user-defined minimum size
        Default minimum size is 5 
        
    INPUT
    -----
        Clustering obtained with MCL (dump file)
        1 line = 1 cluster (sequences in a cluster are separated by a tab)
        
    OUTPUT
    ------
        2 files (same format as input file) :
            - Files containing clusters with the minimum required size
            - Files containing clusters not retained by filtration
    """
        
    with open(args.network ,"r") as file :
        
        for line in file:
            list_line = len(line.split("\t"))
    
            #################################################################
            ############### Clusters retained after filtration ##############
            #################################################################
            
            if int(list_line) >= int(args.min):
                with open(f"conserved_cluster_{args.inflation}.txt", 'a', 
                          encoding = 'utf8') as f:
                    f.write(line)

            #################################################################
            ############### Clusters deleted after filtration ###############
            #################################################################
            
            else:
                with open("deleted_clusters_{args.inflation}.txt", 'a', 
                          encoding = 'utf8') as f:                
                    f.write(line)


if __name__ == '__main__':
    args = get_args()
    main(args)