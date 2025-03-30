#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 10 15:18:40 2025

@author: jrousseau
"""


from argparse import ArgumentParser
import json
import os


def main(args):

    with open(args.diameter, 'r') as f_json:
        d_diameter = json.load(f_json)

    with open(args.hom_sc, "r") as f_input:
        with open("temporary", "w") as f_tmp:
            for position, line in enumerate(f_input):
                l_line = line.strip().split("\t")
                first_part = l_line[:2]
                second_part = l_line[2:]
                if position == 0:
                    new_line = first_part + ["diameter"] + second_part
                else:
                    new_line = first_part + [str(d_diameter[first_part[0]])] + second_part
                
                f_tmp.write('\t'.join(new_line) + '\n')
                
    os.replace("temporary", f"clusters_metrics_{args.basename}.tsv")
                    

def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-d", "--diameter", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-hs", "--hom_sc", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    return parser.parse_args()


if __name__ == '__main__':
    args = get_args()
    main(args)
