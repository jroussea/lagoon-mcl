#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 21:39:42 2024

@author: jrousseau
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
    
    parser.add_argument("-a", "--alignment", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)
    
    parser.add_argument("-b", "--basename", type = str,
                        help = "Network obtained after clustering with MCL", 
                        required = True)

    return parser.parse_args()


def read_network_file(network):
    """


    Parameters
    ----------
    network : TYPE
        DESCRIPTION.

    Returns
    -------
    d_network : TYPE
        DESCRIPTION.

    """
    d_network = dict()

    with open(network, 'r') as rename_file:
        #for position, sequence in enumerate(rename_file):
        #    sequence = sequence.strip()
        #    l_sequence = sequence.split('\t')
        
        for sequence in rename_file:
            l_sequence = sequence.rstrip("\n").split('\t')

            d_network[l_sequence[1]] = l_sequence[0]

    return d_network


def alignments_selection(diamond, d_network, basename):
    """


    Parameters
    ----------
    diamond : TYPE
        DESCRIPTION.
    d_network : TYPE
        DESCRIPTION.

    Returns
    -------
    d_edge : TYPE
        DESCRIPTION.

    """
    f_edge = open(f"edges_{basename}.tsv", 'w')

    with open(diamond, 'r') as f_alignment:
        #for position, alignment in enumerate(f_alignment):
        #    s_alignment = alignment.strip()
        #    l_alignment = s_alignment.split('\t')

        for alignment in f_alignment:
            l_alignment = alignment.rstrip("\n").split('\t')

            if l_alignment[0] in d_network and l_alignment[4] in d_network:
                if str(d_network[l_alignment[0]]) == str(d_network[l_alignment[4]]):
                    covQ = (int(l_alignment[3]) - int(l_alignment[2]) + 1) / int(l_alignment[1]) * 100
                    covS = (int(l_alignment[7]) - int(l_alignment[6]) + 1) / int(l_alignment[5]) * 100
                    diff_cov = abs(covQ - covS)
                    l_output = [l_alignment[0], l_alignment[1], l_alignment[2], l_alignment[3],
                                l_alignment[4], l_alignment[5], l_alignment[6], l_alignment[7],
                                l_alignment[8], l_alignment[9], l_alignment[10], l_alignment[11],
                                l_alignment[12], str(round(diff_cov, 2)), d_network[l_alignment[0]]]
                    f_edge.write('\t'.join(l_output) + '\n')

    f_edge.close()
    

def main(args):

    d_network = read_network_file(args.network)

    alignments_selection(args.alignment, d_network, args.basename)


if __name__ == '__main__':
    args = get_args()
    main(args)







