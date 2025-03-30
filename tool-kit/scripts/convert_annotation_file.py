#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 20 15:29:54 2025

@author: jrousseau
"""


from argparse import ArgumentParser


def get_args():
    """
    Parse arguments
    """
    parser = ArgumentParser(description="")
    
    parser.add_argument("-a", "--annotation", type = str,
                        help = "alphafold alignment", 
                        required = True)
    
    parser.add_argument("-d", "--delemiter", type = str,
                        help = "alphafold alignment", 
                        required = False,
                        default = "\t")
                        
    parser.add_argument("-o", "--output", type = str,
                        help = "output file and path", 
                        required = True)               
    
    return parser.parse_args()


def read_annotation_file(annotation, delemiter):
    """
    

    Parameters
    ----------
    annotation : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    d_sequence = dict()
    
    with open(annotation, "r") as f_annotation:
        
        for position, sequence in enumerate(f_annotation):
            
            sequence = sequence.strip()
            l_sequence = sequence.split(delemiter)
            
            if l_sequence[0] not in d_sequence.keys():
                
                d_sequence[l_sequence[0]] = {l_sequence[1]}
            
            elif l_sequence[0] in d_sequence.keys():
                
                d_sequence[l_sequence[0]].update({l_sequence[1]})
    
    return d_sequence


def write_annotation_file(output, d_sequence):
    """
    

    Parameters
    ----------
    annotation : TYPE
        DESCRIPTION.
    d_sequence : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    f_annotation = open(output, "w")
    
    f_annotation.write('\t'.join(["sequence_id", "label"]) + '\n')
    
    for key, value in d_sequence.items():
        
        value = ";".join(value)
        
        l_sequence = [key, value]
        
        f_annotation.write('\t'.join(l_sequence) + '\n')
        
    f_annotation.close()


def main(args):
    
    d_sequence = read_annotation_file(args.annotation, args.delemiter)
    write_annotation_file(args.output, d_sequence)


if __name__ == '__main__':
    args = get_args()
    main(args)
